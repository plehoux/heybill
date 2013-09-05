require 'ostruct'
require 'chronic'
require 'open-uri'
require 'pathname'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.run_server = false
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end
Capybara.current_driver = :poltergeist

module Heybill
  class Provider
    include Capybara::DSL
    include Utils

    attr_accessor :save_to, :from, :to

    def initialize options
      self.from = Chronic.parse(options[:from]).to_date
      self.to = Chronic.parse(options[:to]).to_date
      self.save_to = Pathname.new(options[:save_to]) || Pathname.new('./')
      paper_size = { format: 'Letter',  border: '0.50in' }
    end

    def fetch
      self.class.steps.each do |step|
        say "#{humanize(step)}..." unless "#{step}".start_with? 'ask_'
        unless send(step)
          say "There was a problem trying to #{humanize(step)}"
          break
        end
      end
    end

    def provider_name
      humanize(underscore(self.class.name.split('::').last))
    end

    def save_page_as_bill(date)
      path = save_to + Bill.new(provider_name, date).file_name
      save_screenshot(path)
    end

    def save_pdf_as_bill(date, url, session_cookie)
      path = save_to + Bill.new(provider_name, date).file_name
      File.open(path, 'w') do |saved_file|
        open(url,"Cookie" => session_cookie) do |file|
          saved_file.write(file.read)
        end
      end
    end

    def paper_size=(size)
      page.driver.paper_size = size
    end

    class << self
      def fetch(options)
        self.new(options).fetch
      end

      def ask(name, &block)
        block ||=
          if name == :password
            -> {@password = ask("Password?  ") { |q| q.echo = false }}
          else
            -> {instance_variable_set("@#{name}", ask("#{humanize(name)}?  "))}
          end
        instance_define_method "ask_#{name}", block
      end

      def log_in(&block)
        instance_define_method __method__, block
      end

      def fetch_bills(&block)
        instance_define_method __method__, block
      end

      def steps; @steps end

      def instance_define_method(name, block = nil)
        (@steps ||= []) << name
        block ||= -> {false}
        instance_eval { define_method name, block }
      end

      def all
        Dir[File.dirname(__FILE__) + '/providers/*.rb'].map do |path|
          OpenStruct.new({
            name: File.basename(path, ".rb"),
            path: path
          })
        end
      end
    end
  end
end
