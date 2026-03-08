# frozen_string_literal: true

module GuardrailsRuby
  class Middleware
    def initialize(client, &block)
      @client = client
      @guard = Guard.new(&block)
    end

    def chat(input, **options)
      @guard.call(input) do |sanitized_input|
        @client.chat(sanitized_input, **options)
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @client.respond_to?(method_name, include_private) || super
    end

    private

    def method_missing(method_name, *args, **kwargs, &block)
      if @client.respond_to?(method_name)
        @client.send(method_name, *args, **kwargs, &block)
      else
        super
      end
    end
  end
end
