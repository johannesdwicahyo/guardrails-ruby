# frozen_string_literal: true

module GuardrailsRuby
  module Redactors
    class PIIRedactor
      # Reuse patterns from Checks::PII
      PATTERNS = GuardrailsRuby::Checks::PII::PATTERNS
      REDACT_MAP = GuardrailsRuby::Checks::PII::REDACT_MAP

      # Redact all PII from the given text, returning a new string.
      #
      #   GuardrailsRuby::Redactors::PIIRedactor.redact("My SSN is 123-45-6789")
      #   # => "My SSN is [SSN REDACTED]"
      #
      def self.redact(text, types: nil)
        new(types: types).redact(text)
      end

      # Initialize with optional type filter.
      #
      #   redactor = PIIRedactor.new(types: [:ssn, :email])
      #   redactor.redact("Call 555-123-4567, SSN 123-45-6789")
      #   # => "Call 555-123-4567, SSN [SSN REDACTED]"
      #
      def initialize(types: nil)
        @types = types&.map(&:to_sym)
      end

      # Redact PII from text. Returns a new string with PII replaced by placeholders.
      def redact(text)
        result = text.dup
        active_patterns.each do |type, pattern|
          result.gsub!(pattern, REDACT_MAP[type])
        end
        result
      end

      # Detect PII in text without redacting. Returns a hash of { type => [matches] }.
      def detect(text)
        found = {}
        active_patterns.each do |type, pattern|
          matches = text.scan(pattern)
          found[type] = matches if matches.any?
        end
        found
      end

      private

      def active_patterns
        if @types
          PATTERNS.select { |type, _| @types.include?(type) }
        else
          PATTERNS
        end
      end
    end
  end
end
