# frozen_string_literal: true

require_relative "lib/guardrails_ruby/version"

Gem::Specification.new do |spec|
  spec.name = "guardrails-ruby"
  spec.version = GuardrailsRuby::VERSION
  spec.authors = ["Johannes Dwi Cahyo"]
  spec.license = "MIT"

  spec.summary = "Input/output validation and safety framework for LLM applications in Ruby"
  spec.homepage = "https://github.com/johannesdwicahyo/guardrails-ruby"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[test/ spec/ features/ .git .github])
    end
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
