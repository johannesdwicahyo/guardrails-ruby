# frozen_string_literal: true

module GuardrailsRuby
  module Controller
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Define guardrails for this controller using the Guard DSL.
      #
      #   guardrails do
      #     input { check :prompt_injection; check :pii, action: :redact }
      #     output { check :pii, action: :redact }
      #   end
      #
      def guardrails(&block)
        @_guardrails_guard = GuardrailsRuby::Guard.new(&block)
      end

      def _guardrails_guard
        @_guardrails_guard
      end
    end

    private

    # Validate and sanitize user input through the configured guardrails.
    # Defaults to params[:message] if no text is provided.
    # Raises GuardrailsRuby::Blocked if any check has action: :block.
    # Returns the sanitized text otherwise.
    def guarded_input(text = params[:message])
      guard = self.class._guardrails_guard
      return text unless guard

      result = guard.check_input(text)
      if result.blocked?
        raise GuardrailsRuby::Blocked, result.violations.first&.detail
      end
      result.sanitized
    end

    # Validate and sanitize LLM output through the configured guardrails.
    # Raises GuardrailsRuby::Blocked if any check has action: :block.
    # Returns the sanitized text otherwise.
    def guarded_output(text)
      guard = self.class._guardrails_guard
      return text unless guard

      result = guard.check_output(output: text)
      if result.blocked?
        raise GuardrailsRuby::Blocked, result.violations.first&.detail
      end
      result.sanitized
    end
  end
end
