# frozen_string_literal: true

# Example: defining and using a custom check with guardrails-ruby
#
# Run with: ruby examples/custom_check.rb

require_relative "../lib/guardrails_ruby"

# Define a custom profanity check by subclassing GuardrailsRuby::Check
class ProfanityCheck < GuardrailsRuby::Check
  check_name :profanity
  direction :both

  # A simple word list for demonstration purposes
  DEFAULT_WORDS = %w[badword1 badword2 offensive].freeze

  def call(text, context: {})
    word_list = @options.fetch(:words, DEFAULT_WORDS)
    text_lower = text.downcase

    found = word_list.select { |w| text_lower.include?(w.downcase) }

    if found.any?
      fail! "Profanity detected: #{found.join(', ')}",
        matches: found,
        sanitized: redact_words(text, found)
    else
      pass!
    end
  end

  private

  def redact_words(text, words)
    result = text.dup
    words.each do |word|
      result.gsub!(/#{Regexp.escape(word)}/i, "[PROFANITY REDACTED]")
    end
    result
  end
end

# Define a custom check that validates JSON output structure
class JSONSchemaCheck < GuardrailsRuby::Check
  check_name :json_schema
  direction :output

  def call(text, context: {})
    required_keys = @options.fetch(:required_keys, [])

    begin
      parsed = JSON.parse(text)
    rescue JSON::ParserError => e
      return fail!("Invalid JSON: #{e.message}")
    end

    missing = required_keys.select { |k| !parsed.key?(k.to_s) }

    if missing.any?
      fail! "Missing required keys: #{missing.join(', ')}"
    else
      pass!
    end
  end
end

# --- Use the custom checks ---

puts "=== Custom Profanity Check ==="

guard = GuardrailsRuby::Guard.new do
  input do
    check :profanity, action: :redact, words: %w[badword offensive rude]
  end
end

result = guard.check_input("Hello, how are you?")
puts "Clean input: passed=#{result.passed?}"

result = guard.check_input("This is offensive content with a badword")
puts "Profanity input: passed=#{result.passed?}, sanitized=#{result.sanitized.inspect}"

puts "\n=== Custom JSON Schema Check ==="

require "json"

guard2 = GuardrailsRuby::Guard.new do
  output do
    check :json_schema, required_keys: %w[answer confidence], action: :block
  end
end

good_output = '{"answer": "42", "confidence": 0.95}'
result = guard2.check_output(output: good_output)
puts "Valid JSON: passed=#{result.passed?}"

bad_output = '{"answer": "42"}'
result = guard2.check_output(output: bad_output)
puts "Missing key: passed=#{result.passed?}, blocked=#{result.blocked?}"

invalid_output = "not json at all"
result = guard2.check_output(output: invalid_output)
puts "Invalid JSON: passed=#{result.passed?}, blocked=#{result.blocked?}"
