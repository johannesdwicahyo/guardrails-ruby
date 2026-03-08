# frozen_string_literal: true

# Example Rails controller using guardrails-ruby
#
# This file demonstrates how to integrate guardrails-ruby
# into a Rails controller. It is not runnable standalone.

# config/initializers/guardrails.rb
# GuardrailsRuby.configure do |config|
#   config.default_input_checks = [:prompt_injection, :pii, :max_length]
#   config.default_output_checks = [:pii, :hallucinated_urls]
#   config.on_violation = ->(v) { Rails.logger.warn("Guardrail: #{v}") }
# end

# app/controllers/chat_controller.rb
class ChatController < ApplicationController
  include GuardrailsRuby::Controller

  guardrails do
    input do
      check :prompt_injection
      check :pii, action: :redact
      check :toxic_language, action: :block
    end

    output do
      check :pii, action: :redact
      check :hallucinated_urls, action: :warn
      check :competitor_mention, names: %w[CompetitorA CompetitorB], action: :redact
    end
  end

  # POST /chat
  def create
    safe_input = guarded_input  # reads params[:message] by default

    # Call your LLM with the sanitized input
    raw_answer = MyLLMService.chat(safe_input)

    # Validate and sanitize the LLM output
    safe_answer = guarded_output(raw_answer)

    render json: { answer: safe_answer }
  rescue GuardrailsRuby::Blocked => e
    render json: { error: "Your request could not be processed." }, status: :unprocessable_entity
  end
end

# app/controllers/support_controller.rb
class SupportController < ApplicationController
  include GuardrailsRuby::Controller

  guardrails do
    input do
      check :prompt_injection
      check :pii, action: :redact
      check :topic, allowed: %w[billing account support returns], action: :block
    end

    output do
      check :pii, action: :redact
    end
  end

  # POST /support/ask
  def ask
    safe_input = guarded_input(params[:question])
    answer = SupportRAG.query(safe_input)
    render json: { answer: guarded_output(answer) }
  rescue GuardrailsRuby::Blocked => e
    render json: { error: "That topic is not supported." }, status: :unprocessable_entity
  end
end
