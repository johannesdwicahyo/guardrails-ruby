# frozen_string_literal: true

require_relative "test_helper"

class TestMaxLength < Minitest::Test
  def test_passes_under_char_limit
    check = GuardrailsRuby::Checks::MaxLength.new(chars: 100)
    result = check.call("Short text")
    assert result.passed?
  end

  def test_fails_over_char_limit
    check = GuardrailsRuby::Checks::MaxLength.new(chars: 5)
    result = check.call("This is too long")
    refute result.passed?
  end

  def test_passes_under_token_limit
    check = GuardrailsRuby::Checks::MaxLength.new(tokens: 100)
    result = check.call("Short text")
    assert result.passed?
  end

  def test_fails_over_token_limit
    check = GuardrailsRuby::Checks::MaxLength.new(tokens: 1)
    result = check.call("This has many tokens in it")
    refute result.passed?
  end
end
