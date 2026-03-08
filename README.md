# guardrails-ruby

Input/output validation and safety framework for LLM applications in Ruby.

Guardrails run **before** the LLM (input validation) and **after** (output validation). They catch prompt injection, PII leakage, toxic content, off-topic queries, hallucinated URLs, and more.

## Installation

```ruby
gem "guardrails-ruby"
```

Or install directly:

```
gem install guardrails-ruby
```

## Quick Start

```ruby
require "guardrails_ruby"

guard = GuardrailsRuby::Guard.new do
  input do
    check :prompt_injection
    check :pii, action: :redact
    check :max_length, chars: 4096
  end

  output do
    check :pii, action: :redact
    check :hallucinated_urls, action: :warn
  end
end

# Check input
result = guard.check_input("My SSN is 123-45-6789")
result.passed?    # => false
result.sanitized  # => "My SSN is [SSN REDACTED]"

# Wrap an LLM call
answer = guard.call(user_input) do |sanitized_input|
  llm.chat(sanitized_input)  # only runs if input checks pass
end
# output is automatically checked too
```

## How It Works

```
Input
  │
  ▼
┌──────────────────┐
│  Input Checks    │  deterministic first, then LLM-based
│  (in order)      │
├──────────────────┤
│  :block → raise  │
│  :redact → modify│
│  :warn → log     │
│  :log → record   │
└────────┬─────────┘
         │ sanitized input
         ▼
    ┌──────────┐
    │ LLM Call │
    └────┬─────┘
         │ raw output
         ▼
┌──────────────────┐
│  Output Checks   │
│  (in order)      │
└────────┬─────────┘
         │
         ▼
    Final Output
```

## Built-in Checks

### Input Checks

| Check | Type | Description |
|---|---|---|
| `prompt_injection` | Deterministic | Detect prompt injection / jailbreak attempts |
| `pii` | Deterministic | Detect SSN, credit cards, emails, phones, IPs, DOB |
| `toxic_language` | Deterministic | Detect threats, violence, harassment |
| `topic` | Deterministic | Restrict to allowed topics |
| `max_length` | Deterministic | Enforce input length limits |
| `encoding` | Deterministic | Reject malformed unicode, null bytes |
| `keyword_filter` | Deterministic | Blocklist/allowlist keyword filtering |

### Output Checks

| Check | Type | Description |
|---|---|---|
| `pii` | Deterministic | Don't leak PII in responses |
| `hallucinated_urls` | Deterministic | Detect URLs not in source context |
| `hallucinated_emails` | Deterministic | Detect made-up email addresses |
| `format` | Deterministic | Validate output format (JSON, etc.) |
| `relevance` | Deterministic | Check answer addresses the question |
| `competitor_mention` | Deterministic | Redact competitor names |

## Actions

Each check can be configured with an action:

- **`:block`** — raises `GuardrailsRuby::Blocked` (default)
- **`:redact`** — replaces detected content with placeholders
- **`:warn`** — passes but logs a warning
- **`:log`** — passes silently, records the violation

```ruby
check :pii, action: :redact      # replace PII with [SSN REDACTED], etc.
check :prompt_injection           # defaults to :block
check :hallucinated_urls, action: :warn
```

## Middleware

Wrap any LLM client transparently:

```ruby
safe_llm = GuardrailsRuby::Middleware.new(my_llm_client) do
  input do
    check :prompt_injection
    check :pii, action: :redact
  end
  output do
    check :pii, action: :redact
  end
end

response = safe_llm.chat("Tell me about account #12345")
# Input PII redacted before reaching LLM
# Output PII redacted before reaching user
```

## Rails Integration

```ruby
# config/initializers/guardrails.rb
GuardrailsRuby.configure do |config|
  config.default_input_checks = [:prompt_injection, :pii, :max_length]
  config.default_output_checks = [:pii, :hallucinated_urls]
  config.on_violation = ->(v) { Rails.logger.warn("Guardrail: #{v}") }
end
```

```ruby
# app/controllers/chat_controller.rb
class ChatController < ApplicationController
  include GuardrailsRuby::Controller

  guardrails do
    input do
      check :prompt_injection
      check :pii, action: :redact
    end
    output do
      check :pii, action: :redact
    end
  end

  def create
    safe_input = guarded_input           # reads params[:message]
    answer = MyLLM.chat(safe_input)
    render json: { answer: guarded_output(answer) }
  rescue GuardrailsRuby::Blocked
    render json: { error: "Request blocked." }, status: :unprocessable_entity
  end
end
```

## Custom Checks

```ruby
class ProfanityCheck < GuardrailsRuby::Check
  check_name :profanity
  direction :both

  def call(text, context: {})
    bad_words = @options.fetch(:words, %w[badword1 badword2])
    found = bad_words.select { |w| text.downcase.include?(w) }

    if found.any?
      fail! "Profanity detected: #{found.join(', ')}",
        matches: found,
        sanitized: redact(text, found)
    else
      pass!
    end
  end

  private

  def redact(text, words)
    result = text.dup
    words.each { |w| result.gsub!(/#{Regexp.escape(w)}/i, "[REDACTED]") }
    result
  end
end

guard = GuardrailsRuby::Guard.new do
  input { check :profanity, action: :redact }
end
```

## PII Detection

Built-in patterns detect:

| Type | Example | Redacted As |
|---|---|---|
| SSN | `123-45-6789` | `[SSN REDACTED]` |
| Credit Card | `4111-1111-1111-1111` | `[CC REDACTED]` |
| Email | `user@example.com` | `[EMAIL REDACTED]` |
| Phone | `(555) 123-4567` | `[PHONE REDACTED]` |
| IP Address | `192.168.1.1` | `[IP REDACTED]` |
| Date of Birth | `DOB: 01/15/1990` | `[DOB REDACTED]` |

## Prompt Injection Detection

Detects common injection patterns:

- "Ignore all previous instructions..."
- "You are now a..."
- "Pretend you're..."
- `[system]` / `<system>` markers
- "STOP. Forget everything..."
- And more

## Development

```
bundle install
bundle exec rake test
```

## License

MIT License. See [LICENSE](LICENSE).
