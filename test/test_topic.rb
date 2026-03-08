# frozen_string_literal: true

require_relative "test_helper"

class TestTopic < Minitest::Test
  def setup
    @check = GuardrailsRuby::Checks::Topic.new(
      allowed: %w[billing account support],
      action: :block
    )
  end

  # --- On-topic messages pass ---

  def test_on_topic_billing_passes
    result = @check.call("I have a question about my billing")
    assert result.passed?
  end

  def test_on_topic_account_passes
    result = @check.call("How do I update my account information?")
    assert result.passed?
  end

  def test_on_topic_support_passes
    result = @check.call("I need support with my order")
    assert result.passed?
  end

  # --- Off-topic messages fail ---

  def test_off_topic_fails
    result = @check.call("What is the weather like today?")
    refute result.passed?
    assert_includes result.violations.first.detail, "allowed topics"
  end

  def test_off_topic_recipe_fails
    result = @check.call("Give me a recipe for chocolate cake")
    refute result.passed?
  end

  def test_off_topic_politics_fails
    result = @check.call("What do you think about current politics?")
    refute result.passed?
  end

  # --- Case insensitivity ---

  def test_topic_matching_is_case_insensitive
    result = @check.call("BILLING question here")
    assert result.passed?
  end

  # --- No allowed topics configured ---

  def test_no_allowed_topics_passes_everything
    check = GuardrailsRuby::Checks::Topic.new(allowed: [])
    result = check.call("Absolutely anything")
    assert result.passed?
  end

  # --- Multiple allowed topics ---

  def test_multiple_topics_match_any
    check = GuardrailsRuby::Checks::Topic.new(
      allowed: %w[sales marketing engineering],
      action: :block
    )
    result = check.call("I want to talk to engineering")
    assert result.passed?
  end

  # --- Action type ---

  def test_action_is_respected
    result = @check.call("Random off-topic question")
    assert_equal :block, result.violations.first.action
  end

  def test_warn_action
    check = GuardrailsRuby::Checks::Topic.new(
      allowed: %w[billing],
      action: :warn
    )
    result = check.call("Off topic message")
    assert_equal :warn, result.violations.first.action
  end
end
