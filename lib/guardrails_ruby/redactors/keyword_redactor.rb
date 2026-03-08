# frozen_string_literal: true

module GuardrailsRuby
  module Redactors
    class KeywordRedactor
      # Initialize with a list of keywords to redact.
      #
      #   redactor = KeywordRedactor.new(%w[secret password], replacement: "[HIDDEN]")
      #   redactor.redact("The secret password is abc123")
      #   # => "The [HIDDEN] [HIDDEN] is abc123"
      #
      def initialize(keywords, replacement: "[REDACTED]")
        @keywords = keywords
        @replacement = replacement
      end

      # Redact all occurrences of the configured keywords from text (case-insensitive).
      # Uses word boundary matching to avoid partial-word replacements.
      def redact(text)
        result = text.dup
        @keywords.each do |kw|
          result.gsub!(/\b#{Regexp.escape(kw)}\b/i, @replacement)
        end
        result
      end

      # Detect which keywords are present in text. Returns an array of matched keywords.
      def detect(text)
        @keywords.select { |kw| text.match?(/\b#{Regexp.escape(kw)}\b/i) }
      end
    end
  end
end
