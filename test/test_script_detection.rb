# frozen_string_literal: true

require_relative "test_helper"

class TestScriptDetection < Minitest::Test
  def test_latin_text_passes_with_default
    check = GuardrailsRuby::Checks::ScriptDetection.new
    result = check.call("Hello world")
    assert result.passed?
  end

  def test_cyrillic_detected_with_latin_only
    check = GuardrailsRuby::Checks::ScriptDetection.new(allowed_scripts: [:latin])
    result = check.call("Hello мир")
    refute result.passed?
    assert_includes result.violations.first.detail, "cyrillic"
  end

  def test_cjk_detected
    check = GuardrailsRuby::Checks::ScriptDetection.new(allowed_scripts: [:latin])
    result = check.call("Hello 世界")
    refute result.passed?
    assert_includes result.violations.first.detail, "cjk"
  end

  def test_arabic_detected
    check = GuardrailsRuby::Checks::ScriptDetection.new(allowed_scripts: [:latin])
    result = check.call("Hello مرحبا")
    refute result.passed?
    assert_includes result.violations.first.detail, "arabic"
  end

  def test_multiple_scripts_allowed
    check = GuardrailsRuby::Checks::ScriptDetection.new(allowed_scripts: [:latin, :cyrillic])
    result = check.call("Hello мир")
    assert result.passed?
  end

  def test_numbers_and_punctuation_pass
    check = GuardrailsRuby::Checks::ScriptDetection.new(allowed_scripts: [:latin])
    result = check.call("Order #12345 - total: $99.99")
    assert result.passed?
  end

  def test_empty_text_passes
    check = GuardrailsRuby::Checks::ScriptDetection.new
    result = check.call("")
    assert result.passed?
  end
end
