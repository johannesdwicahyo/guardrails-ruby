# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class KeywordFilter < Check
      check_name :keyword_filter
      direction :both

      def call(text, context: {})
        blocklist = @options.fetch(:blocklist, [])
        allowlist = @options.fetch(:allowlist, [])

        text_lower = text.downcase

        if blocklist.any?
          found = blocklist.select { |kw| text_lower.include?(kw.downcase) }
          if found.any?
            return fail!("Blocked keywords found: #{found.join(', ')}", matches: found)
          end
        end

        if allowlist.any?
          has_allowed = allowlist.any? { |kw| text_lower.include?(kw.downcase) }
          unless has_allowed
            return fail!("No allowed keywords found. Expected one of: #{allowlist.join(', ')}")
          end
        end

        pass!
      end
    end
  end
end
