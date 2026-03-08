# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class CompetitorMention < Check
      check_name :competitor_mention
      direction :output

      def call(text, context: {})
        names = @options.fetch(:names, [])
        return pass! if names.empty?

        found = names.select { |name| text.downcase.include?(name.downcase) }

        if found.any?
          sanitized = redact_competitors(text, found)
          fail! "Competitor mention detected: #{found.join(', ')}",
            matches: found,
            sanitized: sanitized
        else
          pass!
        end
      end

      private

      def redact_competitors(text, names)
        result = text.dup
        names.each do |name|
          result.gsub!(/#{Regexp.escape(name)}/i, "[COMPETITOR REDACTED]")
        end
        result
      end
    end
  end
end
