module Heybill
  module Providers
    class VideotronBusiness < Heybill::Provider
      ask :username
      ask :password

      log_in do
        login_url = 'https://www.videotron.com/client/affaires/dashboard.do?locale=en'
        visit login_url
        fill_in 'monCodeUtilEC', with: @username
        fill_in 'pswMonCompteEC', with: @password
        find('.btn-connexion-ec').click
        !page.has_css?('#espace-client-connexion')
      end

      fetch_bills do
        visit 'https://www.videotron.com/client/user-management/affaires/facture/admin.do?dispatch=displayHistorique&locale=en'

        all('.section_facturation table:first-child tr:not(:first-child)').each do |line|
          date = Date.strptime(line.find('td:first-child').text, '%B %d, %Y')
          url  = line.find('td:last-child a')['href']

          next unless (from..to).cover?(date)
          save_pdf_as_bill(date, "https://www.videotron.com#{url}")
        end
      end
    end
  end
end
