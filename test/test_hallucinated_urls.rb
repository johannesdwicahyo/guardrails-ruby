# frozen_string_literal: true

require_relative "test_helper"

class TestHallucinatedURLs < Minitest::Test
  def setup
    @check = GuardrailsRuby::Checks::HallucinatedURLs.new(action: :warn)
  end

  # --- URL in source context passes ---

  def test_url_in_source_context_passes
    source = "Visit https://example.com/help for more info."
    result = @check.call(
      "You can find help at https://example.com/help",
      context: { source_context: source }
    )
    assert result.passed?
  end

  def test_url_subpath_of_source_passes
    source = "Main site: https://example.com"
    result = @check.call(
      "Visit https://example.com/docs for documentation.",
      context: { source_context: source }
    )
    assert result.passed?
  end

  # --- URL not in source context fails ---

  def test_url_not_in_source_fails
    source = "Only visit https://example.com"
    result = @check.call(
      "Try https://totally-made-up.com/page for help.",
      context: { source_context: source }
    )
    refute result.passed?
    assert_includes result.violations.first.detail, "hallucinated"
  end

  def test_url_with_no_source_context_fails
    result = @check.call(
      "Visit https://fake-url.com/page for more info.",
      context: {}
    )
    refute result.passed?
  end

  # --- No URLs passes ---

  def test_no_urls_passes
    result = @check.call("This is a plain text response with no links.")
    assert result.passed?
  end

  # --- Multiple URLs mixed ---

  def test_mixed_urls_some_hallucinated
    source = "Reference: https://real-site.com/docs"
    text = "See https://real-site.com/docs and also https://fake-site.com/page"
    result = @check.call(text, context: { source_context: source })

    refute result.passed?
    matches = result.violations.first.matches
    assert_includes matches, "https://fake-site.com/page"
    refute_includes matches, "https://real-site.com/docs"
  end

  def test_all_urls_in_source_passes
    source = "Links: https://a.com and https://b.com"
    text = "Visit https://a.com or https://b.com"
    result = @check.call(text, context: { source_context: source })
    assert result.passed?
  end

  # --- Case insensitive URL comparison ---

  def test_case_insensitive_comparison
    source = "Visit https://Example.COM/Help"
    result = @check.call(
      "Go to https://example.com/help for help.",
      context: { source_context: source }
    )
    assert result.passed?
  end

  # --- Default action ---

  def test_default_action_is_warn
    check = GuardrailsRuby::Checks::HallucinatedURLs.new
    result = check.call("Visit https://fake.com", context: {})
    assert_equal :warn, result.violations.first.action
  end
end
