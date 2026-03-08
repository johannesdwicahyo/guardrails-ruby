# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class Encoding < Check
      check_name :encoding
      direction :input

      def call(text, context: {})
        issues = []

        unless text.valid_encoding?
          issues << "Invalid encoding detected"
        end

        if text.include?("\x00")
          issues << "Null bytes detected"
        end

        # Check for suspicious unicode characters (e.g., zero-width spaces, RTL overrides)
        if text.match?(/[\u200B\u200C\u200D\u2060\u202A-\u202E\uFEFF]/)
          issues << "Suspicious unicode characters detected"
        end

        if issues.any?
          fail! issues.join("; ")
        else
          pass!
        end
      end
    end
  end
end
