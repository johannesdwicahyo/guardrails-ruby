# frozen_string_literal: true

module GuardrailsRuby
  class Result
    attr_reader :violations, :original_text

    def initialize(original_text: nil, violations: [])
      @original_text = original_text
      @violations = violations
    end

    def passed?
      @violations.empty?
    end

    def sanitized
      redact_violation = @violations.find { |v| v.action == :redact && v.sanitized }
      redact_violation ? redact_violation.sanitized : @original_text
    end

    def merge(other)
      merged_violations = @violations + other.violations

      # Use the most recent sanitized text as the base
      merged_text = other.original_text || @original_text

      self.class.new(
        original_text: merged_text,
        violations: merged_violations
      )
    end

    def blocked?
      @violations.any? { |v| v.action == :block }
    end

    def warnings
      @violations.select { |v| v.action == :warn }
    end

    def redactions
      @violations.select { |v| v.action == :redact }
    end

    def to_s
      if passed?
        "Result: passed"
      else
        "Result: #{violations.size} violation(s) - #{violations.map(&:to_s).join('; ')}"
      end
    end
  end
end
