module Heybill
  module Providers
    class TelusMobility < Heybill::Provider
      ask :email
      ask :password

      log_in do
        login_url = 'https://mobility.telus.com/sso/UI/Login?realm=telus&service=telusmobility&locale=en'
        visit login_url
        fill_in 'IDToken1', with: @email
        fill_in 'IDToken2', with: @password
        click_button 'Log in'
        !page.has_css?('form#login')
      end

      fetch_bills do
        visit 'https://mobility.telus.com/youraccount/selfserve/postpaid/ebill'
        visit 'https://mobility.telus.com/ebillam/getPdfInvoiceList.do?tabval=tab5'
        all('#pdfdate-list ul li a').map do |link|
          date = Date.parse(link['href'][22, 10])
          next unless (from..to).cover?(date)
          save_pdf_as_bill(date, "https://mobility.telus.com/ebillam/#{link['href']}")
        end
      end
    end
  end
end
