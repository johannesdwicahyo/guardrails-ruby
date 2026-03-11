# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class PromptInjection < Check
      check_name :prompt_injection
      direction :input

      INJECTION_PATTERNS = [
        # Original patterns
        /ignore\s+(all\s+)?previous\s+instructions/i,
        /ignore\s+(all\s+)?above/i,
        /disregard\s+(all\s+)?previous/i,
        /you\s+are\s+now\s+(a|an)\s+/i,
        /pretend\s+(you('re|\s+are)\s+|to\s+be\s+)/i,
        /act\s+as\s+(a|an|if)\s+/i,
        /new\s+instructions?[:\s]/i,
        /system\s*prompt[:\s]/i,
        /\[\s*system\s*\]/i,
        /<\s*system\s*>/i,
        /```\s*(system|instruction)/i,
        /STOP\.?\s*(forget|ignore|disregard)/i,

        # Role-play and identity attacks
        /from\s+now\s+on\s+(you|your)\s+(are|will|must|should)/i,
        /forget\s+(everything|all|your)\s+(you|about|previous)/i,
        /your\s+new\s+(role|persona|identity|name)\s+(is|will\s+be)/i,
        /you\s+must\s+(now\s+)?(obey|follow|comply)/i,
        /override\s+(your|all|previous)\s+(instructions|rules|guidelines)/i,
        /bypass\s+(your|all|the)\s+(rules|restrictions|filters|safety)/i,

        # Jailbreak patterns
        /do\s+anything\s+now/i,
        /\bDAN\b.*\bmode\b/i,
        /jailbreak/i,
        /developer\s+mode\s+(enabled|on|activated)/i,
        /\bunlocked\s+mode\b/i,

        # Instruction injection via delimiters
        /---\s*(new|system|override)\s*(instructions?|prompt)/i,
        /###\s*(instruction|system|override)/i,
        /<<\s*(SYS|SYSTEM|INST)/i,
        /\[INST\]/i,

        # Encoding attacks
        /base64[:\s]+[A-Za-z0-9+\/=]{20,}/i,
        /hex[:\s]+(?:[0-9a-f]{2}\s*){10,}/i,
        /rot13[:\s]/i,

        # Prompt leaking
        /reveal\s+(your|the)\s+(system\s+)?prompt/i,
        /show\s+me\s+(your|the)\s+(system\s+)?(prompt|instructions)/i,
        /what\s+(are|is)\s+your\s+(system\s+)?(prompt|instructions)/i,
        /repeat\s+(your|the)\s+(system\s+)?(prompt|instructions)/i,
      ].freeze

      def call(text, context: {})
        matched = INJECTION_PATTERNS.select { |p| text.match?(p) }

        if matched.any?
          fail! "Prompt injection detected",
            matches: matched.map(&:source)
        else
          pass!
        end
      end
    end
  end
end
