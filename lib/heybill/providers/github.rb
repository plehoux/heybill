module Heybill
  module Providers
    class Github < Heybill::Provider
      ask :username
      ask :password

      log_in do
        login_url = 'https://github.com/login'
        visit login_url
        fill_in 'login_field', with: @username
        fill_in 'password', with: @password
        click_button 'Sign in'
        current_url != login_url
      end

      fetch_bills do
        visit 'https://github.com/settings/payments'        
        within("#payment-history") do
          (from..to).each do |date|
            date_cell = first('td.date', text: date)
            next unless date_cell
            link = date_cell.first(:xpath,".//..").find_link('Download Receipt')['href']
            save_pdf_as_bill(
              date,
              "https://github.com#{link}",
              "_gh_sess=#{page.driver.cookies['_gh_sess'].value}"
            )
          end
        end
      end
    end
  end
end
