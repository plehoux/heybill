module Heybill
  module Providers
    class Aws < Heybill::Provider
      USERAGENT = {"User-Agent" => "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36" }
      BASEURL   = 'https://portal.aws.amazon.com/gp/aws'
      
      ask :email
      ask :password

      log_in do
        # Amazon infers cookie support by parsing user-agent, mock with one it supports.
        page.driver.headers = USERAGENT

        login_url = "#{BASEURL}/manageYourAccount"
        visit login_url
        fill_in 'ap_email', with: @email
        fill_in 'ap_password', with: @password

        click_button 'signInSubmit'

        current_url == "#{BASEURL}/manageYourAccount"
      end

      fetch_bills do
        visit "#{BASEURL}/developer/account?action=activity-summary"

        invoices = all('select[name="statementTimePeriod"] option').map do |option|
          next if option.text == 'Current Statement'

          period    = option.text
          timestamp = option.value
          date      = Date.strptime timestamp,'%s'

          (from..to).cover?(date) ? {timestamp: timestamp, date: date, period: period} : nil
        end

        invoices.compact.each do |invoice|
          visit("#{BASEURL}/developer/account/index.html?statementTimePeriod=#{invoice[:timestamp]}")

          find '#activity_table_block div', text: "Statement Period: #{invoice[:period]}"
          
          first('#billingSummary a.hideshowLink').click

          save_pdf_as_bill(invoice[:date], find('a.invoiceLink')['href'], USERAGENT)
        end
      end
    end
  end
end
