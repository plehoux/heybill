module Heybill
  module Providers
    class Pingdom < Heybill::Provider
      ask :email
      ask :password

      log_in do
        login_url = 'https://my.pingdom.com/'
        visit login_url
        fill_in 'email', with: @email
        fill_in 'password', with: @password
        click_button 'Log In'
        !page.has_css?('#loginbox')
      end

      fetch_bills do
        visit 'https://my.pingdom.com/account/invoices'

        invoices = scan_current_page
        while next_page do
          invoices += scan_current_page
          break if @abort
        end

        invoices.each do |invoice|
          save_pdf_as_bill(invoice[:date], "https://my.pingdom.com/account/invoices/download?invoiceid=#{invoice[:invoiceid]}&invoicenumber=#{invoice[:invoicenumber]}")
        end
      end

      def scan_current_page
        all('#invoiceTable tbody tr').map do |line|
          next unless line.has_selector?('.checkboxWrapper')

          date = Date.parse(line.find('td:nth-child(5)').text.strip)
          invoiceid = line.find('.checkboxWrapper input')['value']
          invoicenumber = line.find('td:nth-child(2) a').text

          @abort = (date < from)
          (from..to).cover?(date) ? {date: date, invoiceid: invoiceid, invoicenumber: invoicenumber} : nil
        end.compact
      end

      def next_page
        next_page_link = first('.dataTables_paginate .next.enabled')
        next_page_link ? next_page_link.click : false
      end
    end
  end
end
