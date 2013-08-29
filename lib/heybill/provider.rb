require 'ostruct'
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

    DEFAULT_SAVE_TO_PATH = Pathname.new('./')

    def initialize options
      @from = Date.parse options[:from]
      @to = Date.parse options[:to]
      @save_to = Pathname.new(options[:save_to])
      set_paper_size
    end

    def fetch
      self.class.steps.each do |step|
        say "#{Utils.humanize(step)}..." unless "#{step}".start_with? 'ask_'
        unless send(step)
          say "There was a problem trying to #{Utils.humanize(step)}"
          break
        end
      end
    end

    def save_to_path
      @save_to || DEFAULT_SAVE_TO_PATH
    end

    def save_page_as_bill(file_name)
      save_screenshot(save_to_path + file_name)
    end

    def save_pdf_as_bill(file_name, url, session_cookie)
      File.open(save_to_path + file_name, 'w') do |saved_file|
        open(url,"Cookie" => session_cookie) do |file|
          saved_file.write(file.read)
        end
      end
    end

    def set_paper_size(size = { format: 'Letter',  border: '0.50in' })
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
            -> {instance_variable_set("@#{name}", ask("#{Utils.humanize(name)}?  "))}
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
