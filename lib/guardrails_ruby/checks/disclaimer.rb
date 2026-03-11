# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class Disclaimer < Check
      check_name :disclaimer
      direction :output

      DEFAULT_PHRASES = [].freeze

      def call(text, context: {})
        required = @options.fetch(:required_phrases, DEFAULT_PHRASES)
        return pass! if required.empty?

        missing = required.reject do |phrase|
          text.downcase.include?(phrase.downcase)
        end

        if missing.any?
          fail! "Missing required disclaimers: #{missing.join('; ')}",
            matches: missing
        else
          pass!
        end
      end
    end
  end
end
