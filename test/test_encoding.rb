# frozen_string_literal: true

require_relative "test_helper"

class TestEncoding < Minitest::Test
  def test_passes_normal_text
    check = GuardrailsRuby::Checks::Encoding.new
    result = check.call("Normal text")
    assert result.passed?
  end

  def test_detects_zero_width_spaces
    check = GuardrailsRuby::Checks::Encoding.new
    result = check.call("Hello\u200Bworld")
    refute result.passed?
  end

  def test_detects_rtl_override
    check = GuardrailsRuby::Checks::Encoding.new
    result = check.call("Hello\u202Eworld")
    refute result.passed?
  end
end
