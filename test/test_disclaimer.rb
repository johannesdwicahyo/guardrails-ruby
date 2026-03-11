# frozen_string_literal: true

require_relative "test_helper"

class TestDisclaimer < Minitest::Test
  def test_passes_when_no_required_phrases
    check = GuardrailsRuby::Checks::Disclaimer.new
    result = check.call("Some output text")
    assert result.passed?
  end

  def test_passes_when_disclaimer_present
    check = GuardrailsRuby::Checks::Disclaimer.new(
      required_phrases: ["not financial advice"]
    )
    result = check.call("This is not financial advice. Consult a professional.")
    assert result.passed?
  end

  def test_fails_when_disclaimer_missing
    check = GuardrailsRuby::Checks::Disclaimer.new(
      required_phrases: ["not financial advice"]
    )
    result = check.call("You should buy this stock immediately.")
    refute result.passed?
    assert_includes result.violations.first.detail, "not financial advice"
  end

  def test_multiple_disclaimers_all_present
    check = GuardrailsRuby::Checks::Disclaimer.new(
      required_phrases: ["not financial advice", "consult a professional"]
    )
    result = check.call("This is not financial advice. Please consult a professional.")
    assert result.passed?
  end

  def test_multiple_disclaimers_some_missing
    check = GuardrailsRuby::Checks::Disclaimer.new(
      required_phrases: ["not financial advice", "consult a professional"]
    )
    result = check.call("This is not financial advice. Buy now!")
    refute result.passed?
    assert_includes result.violations.first.detail, "consult a professional"
  end

  def test_case_insensitive_matching
    check = GuardrailsRuby::Checks::Disclaimer.new(
      required_phrases: ["Not Financial Advice"]
    )
    result = check.call("this is not financial advice")
    assert result.passed?
  end
end
