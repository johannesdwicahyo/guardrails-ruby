# frozen_string_literal: true

module GuardrailsRuby
  class Configuration
    attr_accessor :default_input_checks, :default_output_checks,
                  :on_violation, :judge_llm

    def initialize
      @default_input_checks = []
      @default_output_checks = []
      @on_violation = nil
      @judge_llm = nil
    end
  end
end
