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

   def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    def humanize(lower_case_and_underscored_word)
      result = lower_case_and_underscored_word.to_s.dup
      result.tr!('_', ' ')
      result.gsub(/^\w/) { $&.upcase }
    end
  end
end
