# frozen_string_literal: true

require "json"

module GuardrailsRuby
  module Checks
    class Format < Check
      check_name :format
      direction :output

      def call(text, context: {})
        schema = @options.fetch(:schema, {})
        type = schema[:type]&.to_sym

        case type
        when :json
          validate_json(text)
        when :markdown
          pass! # basic acceptance for now
        else
          pass!
        end
      end

      private

      def validate_json(text)
        JSON.parse(text)
        pass!
      rescue JSON::ParserError => e
        fail! "Invalid JSON format: #{e.message}"
      end
    end
  end
end
