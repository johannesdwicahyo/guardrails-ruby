# frozen_string_literal: true

require_relative "test_helper"

class TestKeywordFilter < Minitest::Test
  def test_blocks_blocklisted_keyword
    check = GuardrailsRuby::Checks::KeywordFilter.new(blocklist: ["banned"])
    result = check.call("This is banned content")
    refute result.passed?
  end

  def test_passes_without_blocklisted_keywords
    check = GuardrailsRuby::Checks::KeywordFilter.new(blocklist: ["banned"])
    result = check.call("This is fine content")
    assert result.passed?
  end

  def test_allowlist_passes_allowed
    check = GuardrailsRuby::Checks::KeywordFilter.new(allowlist: ["approved"])
    result = check.call("This is approved content")
    assert result.passed?
  end
end
