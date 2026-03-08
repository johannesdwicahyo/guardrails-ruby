# frozen_string_literal: true

module GuardrailsRuby
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "guardrails_ruby.configure" do
        # Auto-load configuration from config/initializers/guardrails.rb if present.
        # The initializer file should call GuardrailsRuby.configure to set defaults.
      end

      initializer "guardrails_ruby.controller" do
        ActiveSupport.on_load(:action_controller) do
          # Make GuardrailsRuby::Controller available to all controllers
          # but don't include it automatically - controllers opt in via:
          #   include GuardrailsRuby::Controller
        end
      end
    end
  end
end
