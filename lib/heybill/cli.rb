require 'heybill/fetch'

module Heybill
  class CLI < Thor
    desc 'fetch [PROVIDER] ...ARGS', 'Fetch bill(s) from provider'
    subcommand 'fetch', Heybill::Fetch

    desc 'providers', 'List all providers'
    def providers
      Heybill::Provider.all.each do |provider|
        say Heybill::Utils.humanize provider.name
      end
    end
  end
end
