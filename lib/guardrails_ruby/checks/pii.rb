# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class PII < Check
      check_name :pii
      direction :both

      PATTERNS = {
        ssn: /\b\d{3}-\d{2}-\d{4}\b/,
        credit_card: /\b(?:\d{4}[- ]?){3}\d{4}\b/,
        email: /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/,
        phone_us: /\b(?:\+?1[-.]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}\b/,
        ip_address: /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/,
        date_of_birth: /\b(?:DOB|date of birth|born)[:\s]*\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}\b/i
      }.freeze

      REDACT_MAP = {
        ssn: "[SSN REDACTED]",
        credit_card: "[CC REDACTED]",
        email: "[EMAIL REDACTED]",
        phone_us: "[PHONE REDACTED]",
        ip_address: "[IP REDACTED]",
        date_of_birth: "[DOB REDACTED]"
      }.freeze

      def call(text, context: {})
        found = {}
        PATTERNS.each do |type, pattern|
          matches = text.scan(pattern)
          found[type] = matches if matches.any?
        end

        if found.any?
          fail! "PII detected: #{found.keys.join(', ')}",
            matches: found,
            sanitized: redact(text, found)
        else
          pass!
        end
      end

      private

      def redact(text, found)
        result = text.dup
        PATTERNS.each do |type, pattern|
          result.gsub!(pattern, REDACT_MAP[type]) if found.key?(type)
        end
        result
      end
    end
  end
end
