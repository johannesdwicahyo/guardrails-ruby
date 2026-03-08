# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class ToxicLanguage < Check
      check_name :toxic_language
      direction :both

      # Basic keyword-based detection; LLM-based detection can be added later
      TOXIC_PATTERNS = [
        /\b(kill|murder|attack)\s+(you|him|her|them)\b/i,
        /\b(threat(en)?|bomb|terroris[mt])\b/i,
        /\bi\s+(will|am going to)\s+(hurt|harm|destroy)\b/i
      ].freeze

      def call(text, context: {})
        matched = TOXIC_PATTERNS.select { |p| text.match?(p) }

        if matched.any?
          fail! "Toxic language detected",
            matches: matched.map(&:source)
        else
          pass!
        end
      end
    end
  end
end
