# frozen_string_literal: true

require_relative "test_helper"

class TestHallucinatedEmails < Minitest::Test
  def test_passes_with_source_emails
    check = GuardrailsRuby::Checks::HallucinatedEmails.new
    result = check.call("Contact us at info@example.com", context: { source_context: "Email: info@example.com" })
    assert result.passed?
  end

  def test_detects_hallucinated_emails
    check = GuardrailsRuby::Checks::HallucinatedEmails.new
    result = check.call("Contact fake@notreal.com for help", context: { source_context: "No emails here" })
    refute result.passed?
  end

  def test_passes_no_emails_in_text
    check = GuardrailsRuby::Checks::HallucinatedEmails.new
    result = check.call("No emails here", context: { source_context: "Some source" })
    assert result.passed?
  end
end
