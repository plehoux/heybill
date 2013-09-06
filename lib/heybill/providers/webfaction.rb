module Heybill
  module Providers
    class Webfaction < Heybill::Provider
      ask :username
      ask :password

      log_in do
        login_url = 'https://my.webfaction.com/'
        visit login_url
        fill_in 'id_username', with: @username
        fill_in 'id_password', with: @password
        click_button 'Login'
        page.status_code == 200
      end

      fetch_bills do
        visit 'https://my.webfaction.com/transactions'

        scroll_to_load_all_invoices

        invoices = all('a.button', text: 'Invoice').map do |button|
          date = Date.parse(button.first(:xpath,".//..//..").find('.transaction_date').text)
          path = button['href']
          (from..to).cover?(date) ? {path: path, date: date} : nil
        end

        invoices.compact.each do |invoice|
          visit "https://my.webfaction.com#{invoice[:path]}"
          save_page_as_bill invoice[:date]
        end
      end

      def scroll_to_load_all_invoices
        page.evaluate_script 'window.scrollTo(0,document.body.scrollHeight);'
        find('.transaction_description', text: 'Account opened')
      end
    end
  end
end
