# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class MaxLength < Check
      check_name :max_length
      direction :input

      def call(text, context: {})
        max_chars = @options[:chars]
        max_tokens = @options[:tokens]

        if max_chars && text.length > max_chars
          fail! "Input exceeds maximum length of #{max_chars} characters (got #{text.length})"
        elsif max_tokens && estimate_tokens(text) > max_tokens
          fail! "Input exceeds maximum length of #{max_tokens} tokens (estimated #{estimate_tokens(text)})"
        else
          pass!
        end
      end

      private

      # Simple token estimation (~4 chars per token)
      def estimate_tokens(text)
        (text.length / 4.0).ceil
      end
    end
  end
end
