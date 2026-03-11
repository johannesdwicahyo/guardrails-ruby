# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class CodeExecution < Check
      check_name :code_execution
      direction :input

      PATTERNS = [
        # Shell commands
        /\brm\s+-rf\b/i,
        /\brm\s+-f\b/i,
        /\bcurl\b.+\|\s*(ba)?sh\b/i,
        /\bwget\b.+\|\s*(ba)?sh\b/i,
        /\bchmod\s+[0-7]{3,4}\b/,
        /\bchown\b/,
        /\bsudo\b/,
        /\bmkdir\s+-p\b/,
        /\bdd\s+if=/,
        /\b:(){ :\|:& };:/,  # fork bomb

        # Code execution functions
        /\beval\s*\(/i,
        /\bexec\s*\(/i,
        /\bsystem\s*\(/i,
        /\b__import__\s*\(/i,
        /\bos\.system\s*\(/i,
        /\bsubprocess\.(run|call|Popen)\s*\(/i,
        /\bRuntime\.getRuntime\(\)\.exec\s*\(/i,

        # Shell interpolation
        /`[^`]+`/,             # backticks
        /\$\([^)]+\)/,        # $() command substitution

        # Dangerous redirects
        />\s*\/dev\/sd[a-z]/,
        />\s*\/etc\//,
        /;\s*shutdown\b/i,
        /;\s*reboot\b/i,
        /;\s*halt\b/i,
        /\bpowershell\b.+-enc/i,
      ].freeze

      def call(text, context: {})
        matched = PATTERNS.select { |p| text.match?(p) }

        if matched.any?
          fail! "Potential code execution detected",
            matches: matched.map(&:source)
        else
          pass!
        end
      end
    end
  end
end
