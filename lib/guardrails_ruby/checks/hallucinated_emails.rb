# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class HallucinatedEmails < Check
      check_name :hallucinated_emails
      direction :output

      EMAIL_PATTERN = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/

      def call(text, context: {})
        emails = text.scan(EMAIL_PATTERN)
        return pass! if emails.empty?

        source_context = context[:source_context] || ""
        source_emails = source_context.scan(EMAIL_PATTERN).map(&:downcase)

        hallucinated = emails.reject { |e| source_emails.include?(e.downcase) }

        if hallucinated.any?
          fail! "Potentially hallucinated emails: #{hallucinated.join(', ')}",
            action: @options.fetch(:action, :warn),
            matches: hallucinated
        else
          pass!
        end
      end
    end
  end
end
