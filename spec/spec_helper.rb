$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['RAILS_ENV'] = 'test'

require File.expand_path("../dummy/config/environment.rb", __FILE__)

require "database_cleaner"
require "pry"

require 'spree/core/version'
require 'rails/all'
require 'rspec/rails'
require 'klarna_gateway'

require 'spree/testing_support/factories'
require 'factories/klarna_payment_factory'
require 'support/klarna_api_helper'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

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
