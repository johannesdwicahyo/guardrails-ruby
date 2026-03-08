# frozen_string_literal: true

require_relative "test_helper"

class TestFormat < Minitest::Test
  def setup
    @check = GuardrailsRuby::Checks::Format.new(schema: { type: :json })
  end

  # --- Valid JSON passes ---

  def test_valid_json_object_passes
    result = @check.call('{"name": "test", "value": 42}')
    assert result.passed?
  end

  def test_valid_json_array_passes
    result = @check.call('[1, 2, 3]')
    assert result.passed?
  end

  def test_valid_json_string_passes
    result = @check.call('"hello"')
    assert result.passed?
  end

  def test_valid_nested_json_passes
    result = @check.call('{"user": {"name": "test", "roles": ["admin"]}}')
    assert result.passed?
  end

  # --- Invalid JSON fails ---

  def test_invalid_json_fails
    result = @check.call("this is not json")
    refute result.passed?
    assert_includes result.violations.first.detail, "Invalid JSON"
  end

  def test_malformed_json_fails
    result = @check.call('{"key": "value",}')
    refute result.passed?
  end

  def test_incomplete_json_fails
    result = @check.call('{"key":')
    refute result.passed?
  end

  # --- Empty string handling ---

  def test_empty_string_fails_json
    result = @check.call("")
    refute result.passed?
  end

  # --- Markdown type passes (basic acceptance) ---

  def test_markdown_type_passes
    check = GuardrailsRuby::Checks::Format.new(schema: { type: :markdown })
    result = check.call("# Hello\n\nSome text")
    assert result.passed?
  end

  # --- No schema type passes ---

  def test_no_schema_passes
    check = GuardrailsRuby::Checks::Format.new(schema: {})
    result = check.call("anything")
    assert result.passed?
  end

  def test_no_schema_option_passes
    check = GuardrailsRuby::Checks::Format.new
    result = check.call("anything")
    assert result.passed?
  end

  # --- Default action ---

  def test_default_action_is_block
    result = @check.call("not json")
    assert_equal :block, result.violations.first.action
  end
end
