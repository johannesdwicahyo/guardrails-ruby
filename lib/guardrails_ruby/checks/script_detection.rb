# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class ScriptDetection < Check
      check_name :script_detection
      direction :input

      SCRIPTS = {
        latin:      /[\p{Latin}]/,
        cyrillic:   /[\p{Cyrillic}]/,
        arabic:     /[\p{Arabic}]/,
        cjk:        /[\p{Han}]/,
        hangul:     /[\p{Hangul}]/,
        hiragana:   /[\p{Hiragana}]/,
        katakana:   /[\p{Katakana}]/,
        thai:       /[\p{Thai}]/,
        devanagari: /[\p{Devanagari}]/,
        greek:      /[\p{Greek}]/,
        hebrew:     /[\p{Hebrew}]/,
        georgian:   /[\p{Georgian}]/,
        armenian:   /[\p{Armenian}]/,
        ethiopic:   /[\p{Ethiopic}]/,
        tamil:      /[\p{Tamil}]/
      }.freeze

      def call(text, context: {})
        allowed = @options.fetch(:allowed_scripts, [:latin])
        allowed = allowed.map(&:to_sym)

        detected = detect_scripts(text)
        unexpected = detected - allowed

        if unexpected.any?
          fail! "Unexpected scripts detected: #{unexpected.join(', ')}",
            matches: unexpected.map(&:to_s)
        else
          pass!
        end
      end

      private

      def detect_scripts(text)
        found = []
        SCRIPTS.each do |name, pattern|
          found << name if text.match?(pattern)
        end
        found
      end
    end
  end
end
