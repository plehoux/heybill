module Heybill
  module Providers
    class Heroku < Heybill::Provider
      ask :email
      ask :password

      log_in do
        login_url = 'https://id.heroku.com/login'
        visit login_url
        fill_in 'email',    with: @email
        fill_in 'password', with: @password
        click_button 'Log In'
        current_url != login_url
      end

      fetch_bills do
        (from..to).map{ |m| [m.year, m.mon] }.uniq.each do |year_month|
          visit 'https://dashboard.heroku.com/invoices/' + year_month.join('/')
          next if page.status_code == 404
          save_page_as_bill Date.new(*year_month)
        end
      end
    end
  end
end
