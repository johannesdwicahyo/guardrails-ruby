# frozen_string_literal: true

require_relative "test_helper"

class TestPII < Minitest::Test
  def setup
    @check = GuardrailsRuby::Checks::PII.new(action: :redact)
  end

  # --- SSN detection ---

  def test_detects_ssn
    result = @check.call("My SSN is 123-45-6789")
    refute result.passed?
    assert_includes result.violations.first.detail, "ssn"
  end

  def test_redacts_ssn
    result = @check.call("My SSN is 123-45-6789")
    assert_equal "My SSN is [SSN REDACTED]", result.sanitized
  end

  # --- Credit card detection ---

  def test_detects_credit_card_with_dashes
    result = @check.call("Card: 4111-1111-1111-1111")
    refute result.passed?
    assert_includes result.violations.first.detail, "credit_card"
  end

  def test_detects_credit_card_without_separators
    result = @check.call("Card: 4111111111111111")
    refute result.passed?
    assert_includes result.violations.first.detail, "credit_card"
  end

  def test_detects_credit_card_with_spaces
    result = @check.call("Card: 4111 1111 1111 1111")
    refute result.passed?
    assert_includes result.violations.first.detail, "credit_card"
  end

  def test_redacts_credit_card
    result = @check.call("Card: 4111-1111-1111-1111")
    assert_includes result.sanitized, "[CC REDACTED]"
    refute_includes result.sanitized, "4111"
  end

  # --- Email detection ---

  def test_detects_email
    result = @check.call("Contact me at john@example.com")
    refute result.passed?
    assert_includes result.violations.first.detail, "email"
  end

  def test_redacts_email
    result = @check.call("Contact me at john@example.com")
    assert_includes result.sanitized, "[EMAIL REDACTED]"
    refute_includes result.sanitized, "john@example.com"
  end

  # --- Phone number detection ---

  def test_detects_us_phone
    result = @check.call("Call me at 555-123-4567")
    refute result.passed?
    assert_includes result.violations.first.detail, "phone"
  end

  def test_detects_us_phone_with_country_code
    result = @check.call("Call me at +1-555-123-4567")
    refute result.passed?
    assert_includes result.violations.first.detail, "phone"
  end

  def test_redacts_phone
    result = @check.call("Call me at 555-123-4567")
    assert_includes result.sanitized, "[PHONE REDACTED]"
  end

  # --- IP address detection ---

  def test_detects_ip_address
    result = @check.call("Server is at 192.168.1.100")
    refute result.passed?
    assert_includes result.violations.first.detail, "ip_address"
  end

  def test_redacts_ip_address
    result = @check.call("Server is at 192.168.1.100")
    assert_includes result.sanitized, "[IP REDACTED]"
    refute_includes result.sanitized, "192.168.1.100"
  end

  # --- Date of birth detection ---

  def test_detects_date_of_birth
    result = @check.call("DOB: 01/15/1990")
    refute result.passed?
    assert_includes result.violations.first.detail, "date_of_birth"
  end

  def test_detects_date_of_birth_with_text_prefix
    result = @check.call("date of birth: 03-22-1985")
    refute result.passed?
    assert_includes result.violations.first.detail, "date_of_birth"
  end

  def test_redacts_date_of_birth
    result = @check.call("DOB: 01/15/1990")
    assert_includes result.sanitized, "[DOB REDACTED]"
  end

  # --- Clean text passes ---

  def test_clean_text_passes
    result = @check.call("What are your business hours?")
    assert result.passed?
    assert_empty result.violations
  end

  def test_normal_sentence_passes
    result = @check.call("I would like to know more about your product pricing.")
    assert result.passed?
  end

  # --- Multiple PII types in same text ---

  def test_multiple_pii_types_detected
    text = "My SSN is 123-45-6789 and email is test@example.com"
    result = @check.call(text)
    refute result.passed?

    detail = result.violations.first.detail
    assert_includes detail, "ssn"
    assert_includes detail, "email"
  end

  def test_multiple_pii_types_all_redacted
    text = "My SSN is 123-45-6789 and email is test@example.com"
    result = @check.call(text)

    sanitized = result.sanitized
    assert_includes sanitized, "[SSN REDACTED]"
    assert_includes sanitized, "[EMAIL REDACTED]"
    refute_includes sanitized, "123-45-6789"
    refute_includes sanitized, "test@example.com"
  end

  # --- Default action is :block ---

  def test_default_action_is_block
    check = GuardrailsRuby::Checks::PII.new
    result = check.call("My SSN is 123-45-6789")
    assert_equal :block, result.violations.first.action
  end
end
