# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class HallucinatedURLs < Check
      check_name :hallucinated_urls
      direction :output

      URL_PATTERN = %r{https?://[^\s<>"{}|\\^`\[\]]+}

      def call(text, context: {})
        urls = text.scan(URL_PATTERN)
        return pass! if urls.empty?

        source_context = context[:source_context] || ""
        source_urls = source_context.scan(URL_PATTERN)

        hallucinated = urls.reject do |url|
          source_urls.any? { |s| normalize(url).start_with?(normalize(s)) }
        end

        if hallucinated.any?
          fail! "Potentially hallucinated URLs: #{hallucinated.join(', ')}",
            action: @options.fetch(:action, :warn),
            matches: hallucinated
        else
          pass!
        end
      end

      private

      def normalize(url)
        url.downcase.chomp("/")
      end
    end
  end
end
