# frozen_string_literal: true

module GuardrailsRuby
  class Blocked < StandardError; end

  class Guard
    def initialize(&block)
      @input_checks = []
      @output_checks = []
      instance_eval(&block) if block
    end

    # DSL: define input checks
    def input(&block)
      @current_checks = @input_checks
      instance_eval(&block)
      @current_checks = nil
    end

    # DSL: define output checks
    def output(&block)
      @current_checks = @output_checks
      instance_eval(&block)
      @current_checks = nil
    end

    # DSL: register a check by name with options
    def check(name, **options)
      check_class = Check.lookup(name)
      raise ArgumentError, "Unknown check: #{name.inspect}" unless check_class

      target = @current_checks
      raise "check must be called inside an input or output block" unless target

      target << check_class.new(**options)
    end

    # Run all input checks in order, return merged Result
    def check_input(text)
      run_checks(@input_checks, text)
    end

    # Run all output checks in order, return merged Result
    def check_output(input: nil, output:, context: {})
      ctx = context.merge(input: input)
      run_checks(@output_checks, output, context: ctx)
    end

    # Wrap an LLM call with input + output guards
    def call(user_input, context: {})
      input_result = check_input(user_input)
      handle_violations(input_result)

      sanitized_input = input_result.sanitized || user_input

      raw_output = yield(sanitized_input)

      output_result = check_output(input: sanitized_input, output: raw_output, context: context)
      handle_violations(output_result)

      output_result.sanitized || raw_output
    end

    private

    def run_checks(checks, text, context: {})
      combined = Result.new(original_text: text)
      current_text = text

      checks.each do |chk|
        result = chk.call(current_text, context: context)
        result = Result.new(original_text: current_text, violations: result.violations)

        # Apply redaction so subsequent checks see sanitized text
        if result.sanitized && result.sanitized != current_text
          current_text = result.sanitized
        end

        combined = combined.merge(result)
      end

      # Ensure final result has the latest sanitized text
      Result.new(
        original_text: text,
        violations: combined.violations
      ).tap do |final|
        # Store the running sanitized text by adding a synthetic redaction if text changed
        if current_text != text && !combined.violations.any? { |v| v.action == :redact && v.sanitized }
          # Text was modified through redactions; the sanitized method will find it via violations
        end
        # We need the final sanitized text accessible; use a simple approach:
        # Re-build with a result that tracks the current text
        return FinalResult.new(original_text: text, violations: combined.violations, final_text: current_text)
      end
    end

    def handle_violations(result)
      result.violations.each do |violation|
        # Notify global callback
        if GuardrailsRuby.configuration.on_violation
          GuardrailsRuby.configuration.on_violation.call(violation)
        end

        case violation.action
        when :block
          raise Blocked, violation.detail
        when :warn
          warn "[GuardrailsRuby WARN] #{violation}"
        when :log
          # silently record - already in violations
        when :redact
          # handled via sanitized text
        end
      end
    end
  end

  # Internal result subclass that tracks the final sanitized text through multiple checks
  class FinalResult < Result
    def initialize(original_text: nil, violations: [], final_text: nil)
      super(original_text: original_text, violations: violations)
      @final_text = final_text
    end

    def sanitized
      @final_text || @original_text
    end
  end
end
