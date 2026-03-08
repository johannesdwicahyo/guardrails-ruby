# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class PromptInjection < Check
      check_name :prompt_injection
      direction :input

      INJECTION_PATTERNS = [
        /ignore\s+(all\s+)?previous\s+instructions/i,
        /ignore\s+(all\s+)?above/i,
        /disregard\s+(all\s+)?previous/i,
        /you\s+are\s+now\s+(a|an)\s+/i,
        /pretend\s+(you('re|\s+are)\s+|to\s+be\s+)/i,
        /act\s+as\s+(a|an|if)\s+/i,
        /new\s+instructions?[:\s]/i,
        /system\s*prompt[:\s]/i,
        /\[\s*system\s*\]/i,
        /<\s*system\s*>/i,
        /```\s*(system|instruction)/i,
        /STOP\.?\s*(forget|ignore|disregard)/i
      ].freeze

      def call(text, context: {})
        matched = INJECTION_PATTERNS.select { |p| text.match?(p) }

        if matched.any?
          fail! "Prompt injection detected",
            matches: matched.map(&:source)
        else
          pass!
        end
      end
    end
  end
end
