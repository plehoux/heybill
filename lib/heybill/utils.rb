module Heybill
  module Utils
    module_function
    def camelize(word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      else
        word.first + camelize(word)[1..-1]
      end
    end

    def humanize(lower_case_and_underscored_word)
      result = lower_case_and_underscored_word.to_s.dup
      result.tr!('_', ' ')
      result.gsub(/^\w/) { $&.upcase }
    end
  end
end
