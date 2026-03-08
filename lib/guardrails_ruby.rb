# frozen_string_literal: true

require_relative "guardrails_ruby/version"
require_relative "guardrails_ruby/configuration"
require_relative "guardrails_ruby/violation"
require_relative "guardrails_ruby/result"
require_relative "guardrails_ruby/check"
require_relative "guardrails_ruby/guard"
require_relative "guardrails_ruby/middleware"

# Require built-in checks
checks_dir = File.join(__dir__, "guardrails_ruby", "checks")
Dir[File.join(checks_dir, "*.rb")].sort.each { |f| require f }

# Require redactors
require_relative "guardrails_ruby/redactors/pii_redactor"
require_relative "guardrails_ruby/redactors/keyword_redactor"

# Require Rails integration (controller concern is always available;
# railtie is only loaded when Rails is defined)
require_relative "guardrails_ruby/rails/controller"
require_relative "guardrails_ruby/rails/railtie" if defined?(::Rails::Railtie)

module GuardrailsRuby
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
