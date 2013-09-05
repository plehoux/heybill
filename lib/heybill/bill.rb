module Heybill
  class Bill
    def initialize(provider, date)
      @provider = provider
      @date = date
    end

    def file_name
      "#{@date.strftime('%F')} #{@provider}.pdf"
    end
  end
end