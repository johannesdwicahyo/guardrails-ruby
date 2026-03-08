# frozen_string_literal: true

module GuardrailsRuby
  class Check
    @registry = {}

    class << self
      attr_reader :registry

      # DSL: set or get the check name
      def check_name(name = nil)
        if name
          @check_name = name.to_sym
          Check.registry[name.to_sym] = self
        end
        @check_name
      end

      # DSL: set or get the direction
      def direction(dir = nil)
        if dir
          @direction = dir.to_sym
        end
        @direction || :both
      end

      # Look up a check class by its registered name
      def lookup(name)
        registry[name.to_sym]
      end
    end

    attr_reader :options

    def initialize(**options)
      @options = options
    end

    # Override in subclasses
    def call(text, context: {})
      raise NotImplementedError, "#{self.class}#call must be implemented"
    end

    private

    def fail!(detail, action: nil, matches: nil, sanitized: nil)
      act = action || @options.fetch(:action, :block)

      violation = Violation.new(
        type: self.class.check_name,
        detail: detail,
        action: act,
        matches: matches,
        sanitized: sanitized
      )

      Result.new(violations: [violation])
    end

    def pass!
      Result.new
    end
  end
end
