# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','heybill','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'Heybill'
  s.version = Heybill::VERSION
  s.author = 'Philippe-Antoine Lehoux'
  s.email = 'plehoux@gmail.com'
  s.homepage = 'http://ilex.ca'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A command line tool automating the process of fetching invoices/bills from online providers.'
  s.files = %w(LICENSE README.md heybill.gemspec)
  s.files += Dir.glob("lib/**/*.rb")
  s.files += Dir.glob("bin/**/*")
  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'heybill'
  s.add_dependency 'thor', '~> 0.18'
  s.add_dependency 'capybara', '~> 2.1.0'
  s.add_dependency 'plehoux-poltergeist', '~> 1.4.0'
  s.add_dependency 'highline', '~> 1.6.2'
end
