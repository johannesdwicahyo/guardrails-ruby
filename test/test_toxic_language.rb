# frozen_string_literal: true

require_relative "test_helper"

class TestToxicLanguage < Minitest::Test
  def test_passes_clean_text
    check = GuardrailsRuby::Checks::ToxicLanguage.new
    result = check.call("Hello, how are you?")
    assert result.passed?
  end

  def test_detects_toxic_keywords
    check = GuardrailsRuby::Checks::ToxicLanguage.new
    result = check.call("I will kill you")
    refute result.passed?
  end
end
