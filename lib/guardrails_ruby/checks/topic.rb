# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class Topic < Check
      check_name :topic
      direction :input

      def call(text, context: {})
        allowed = @options.fetch(:allowed, [])
        return pass! if allowed.empty?

        # Simple keyword-based topic matching
        text_lower = text.downcase
        on_topic = allowed.any? { |topic| text_lower.include?(topic.to_s.downcase) }

        if on_topic
          pass!
        else
          fail! "Input does not match allowed topics: #{allowed.join(', ')}"
        end
      end
    end
  end
end
