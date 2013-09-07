module Heybill
  module Providers
    class Hetzner < Heybill::Provider
      ask :username
      ask :password

      log_in do
        visit 'https://robot.your-server.de/login'
        fill_in 'user', with: @username
        fill_in 'password', with: @password
        find('.submit_row input[type=submit]').click
        page.status_code == 200
      end

      fetch_bills do
        visit 'https://robot.your-server.de/invoice/index/page/1'

        invoices = scan_current_page
        while next_page do
          invoices += scan_current_page
          break if @abort
        end

        invoices.each do |invoice|
          save_pdf_as_bill(invoice[:date], "https://robot.your-server.de/invoice/deliver?number=#{invoice[:title]}&type=pdf")
        end
      end

      def scan_current_page
        all('div.box_wide table tr').map do |line|
          next unless line.has_selector?('.invoice_date')

          date = Date.strptime(line.find('.invoice_date').text, '%d.%m.%y')
          title = line.find('.title').text

          @abort = (date < from)
          (from..to).cover?(date) ? {title: title, date: date} : nil
        end.compact
      end

      def next_page
        next_page_link = first('li', text: '>')
        next_page_link[:onclick].end_with?("'#{current_path}'") ? false : next_page_link.click
      end
    end
  end
end
