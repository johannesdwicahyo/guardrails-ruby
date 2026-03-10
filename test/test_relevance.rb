# frozen_string_literal: true

require_relative "test_helper"

class TestRelevance < Minitest::Test
  def test_passes_relevant_response
    check = GuardrailsRuby::Checks::Relevance.new
    result = check.call("The weather in Jakarta is hot", context: { input: "What is the weather in Jakarta?" })
    assert result.passed?
  end

  def test_fails_irrelevant_response
    check = GuardrailsRuby::Checks::Relevance.new
    result = check.call("I really enjoy eating pizza and pasta for dinner every night", context: { input: "What is the weather in Jakarta?" })
    refute result.passed?
  end
end
