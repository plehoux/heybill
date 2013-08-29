module Heybill
  class Fetch < Thor
    Heybill::Provider.all.each do |provider|
      desc "fetch #{provider.name}", "Fetch bills from #{provider.name}"
      option :from,    required: true, desc: "e.g. 'june 2012'"
      option :to,      required: true, desc: "e.g. 'june 2013'"
      option :save_to,                 desc: "Default save to present working directory. e.g.  ~/Desktop"
      define_method provider.name do
        Heybill::Providers.const_get("#{Heybill::Utils.camelize(provider.name)}").fetch(options)
      end
    end

    def method_missing(method)
      say "No provider called #{method}"
    end
  end
end
