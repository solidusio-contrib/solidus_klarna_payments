$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['RAILS_ENV'] = 'test'

begin
  require File.expand_path("../dummy/config/environment.rb",  __FILE__)
rescue LoadError
  puts "Could not load dummy application. Please ensure you have run `bundle exec rake test_app`"
end

require "database_cleaner"
require "pry"

require 'spree/core/version'
require 'rails/all'
require 'rspec/rails'
require 'klarna_gateway'

# Feature specs
require 'capybara'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'

require 'vcr'
require 'spree/testing_support/factories'
require 'spree/testing_support/controller_requests'
require 'factories/klarna_payment_factory'
require 'support/klarna_api_helper'
require 'support/site_prism'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.include FactoryGirl::Syntax::Methods
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include_context "Klarna API helper", :klarna_api

  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    DatabaseCleaner.strategy = RSpec.current_example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, timeout: 1.minute, phantomjs_options: ['--load-images=no'])
end
Capybara.javascript_driver = :poltergeist

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.filter_sensitive_data('<ENCODED_AUTH_HEADER>') do
    Base64.strict_encode64("#{ENV.fetch('KLARNA_API_KEY', 'KLARNA_DEFAULT_KEY')}:#{ENV.fetch('KLARNA_API_SECRET', 'KLARNA_DEFAULT_SECRET')}")
  end
end
