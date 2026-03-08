# frozen_string_literal: true

module GuardrailsRuby
  module Checks
    class Relevance < Check
      check_name :relevance
      direction :output

      # This check requires LLM-based evaluation for real accuracy.
      # For now, a simple heuristic: check if any words from the input appear in the output.
      def call(text, context: {})
        input_text = context[:input]
        return pass! unless input_text

        input_words = significant_words(input_text)
        return pass! if input_words.empty?

        output_lower = text.downcase
        overlap = input_words.count { |w| output_lower.include?(w) }
        ratio = overlap.to_f / input_words.size

        if ratio < 0.1 && text.length > 20
          fail! "Output may not be relevant to the input (low keyword overlap)",
            action: @options.fetch(:action, :warn)
        else
          pass!
        end
      end

      private

      STOP_WORDS = %w[the a an is are was were be been being have has had do does did
                      will would shall should may might can could of in to for on with
                      at by from it its this that these those i me my we our you your
                      he she they them his her and or but not no if so as how what when
                      where which who whom why].freeze

      def significant_words(text)
        text.downcase.scan(/\b\w+\b/).reject { |w| STOP_WORDS.include?(w) || w.length < 3 }
      end
    end
  end
end
