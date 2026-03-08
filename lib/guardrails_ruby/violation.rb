# frozen_string_literal: true

module GuardrailsRuby
  class Violation
    ACTIONS = %i[block warn redact log].freeze

    attr_reader :type, :detail, :action, :severity, :matches, :sanitized

    def initialize(type:, detail:, action: :block, severity: nil, matches: nil, sanitized: nil)
      unless ACTIONS.include?(action)
        raise ArgumentError, "Invalid action #{action.inspect}. Must be one of: #{ACTIONS.join(', ')}"
      end

      @type = type
      @detail = detail
      @action = action
      @severity = severity || default_severity(action)
      @matches = matches
      @sanitized = sanitized
    end

    def to_s
      "#{type}: #{detail} (action=#{action})"
    end

    def inspect
      "#<#{self.class} type=#{type.inspect}, detail=#{detail.inspect}, action=#{action.inspect}>"
    end

    private

    def default_severity(action)
      case action
      when :block then :high
      when :redact then :medium
      when :warn then :low
      when :log then :info
      end
    end
  end
end
