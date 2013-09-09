require 'ostruct'
require 'chronic'
require 'open-uri'
require 'pathname'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.run_server = false
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
    js_errors: false,
    phantomjs_logger: File::NULL
  )
end
Capybara.current_driver = :poltergeist
Capybara.ignore_hidden_elements = false

module Heybill
  class Provider
    include Capybara::DSL
    include Utils

    attr_accessor :save_to, :from, :to

    def initialize options
      self.from = Chronic.parse(options[:from], guess: :begin).to_date
      self.to = Chronic.parse(options[:to], guess: :begin).to_date
      self.save_to = Pathname.new(options[:save_to] || Dir.pwd)
      self.paper_size = { format: 'Letter',  border: '0.50in' }
    end

    def fetch
      for step in self.class.steps
        say "<%= color('#{humanize(step)}...', BOLD) %>" unless "#{step}".start_with? 'ask_'
        unless send(step)
          say "There was a problem trying to #{humanize(step)}"
          broke = true; break
        end
      end
      say 'Done!' unless broke
    end

    def provider_name
      humanize(underscore(self.class.name.split('::').last))
    end

    def saved file_name
      say "-> <%= color('#{file_name}', GREEN) %>"
    end

    def save_page_as_bill(date)
      file_name = Bill.new(provider_name, date).file_name
      path = save_to + file_name
      save_screenshot(path)
      saved(file_name)
    end

    def save_pdf_as_bill(date, url)
      file_name = Bill.new(provider_name, date).file_name

      cookies = page.driver.cookies.map do |key, cookie|
        "#{key}=#{cookie.value}"
      end.join(';')

      path = save_to + file_name
      File.open(path, 'w') do |saved_file|
        open(url,"Cookie" => cookies) do |file|
          saved_file.write(file.read)
        end
      end
      saved(file_name)
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
