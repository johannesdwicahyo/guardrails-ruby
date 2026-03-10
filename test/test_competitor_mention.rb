# frozen_string_literal: true

require_relative "test_helper"

class TestCompetitorMention < Minitest::Test
  def test_passes_without_competitors
    check = GuardrailsRuby::Checks::CompetitorMention.new(names: ["Acme"])
    result = check.call("Our product is great")
    assert result.passed?
  end

  def test_detects_competitor_mention
    check = GuardrailsRuby::Checks::CompetitorMention.new(names: ["Acme"])
    result = check.call("Try Acme instead")
    refute result.passed?
  end

  def test_case_insensitive
    check = GuardrailsRuby::Checks::CompetitorMention.new(names: ["Acme"])
    result = check.call("Try ACME instead")
    refute result.passed?
  end
end
