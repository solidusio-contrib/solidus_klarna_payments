require 'spec_helper'

require 'capybara/rspec'
require 'capybara/rails'
require 'site_prism'
require 'support/drivers'
require 'support/wait_for_ajax'
require 'support/shared_contexts/ordering_with_klarna'

# Configure Capybara expected host
$data = TestData.new(ENV['STORE'])
# Capybara.app_host = $data.host

Capybara.default_selector = :css
Capybara.default_max_wait_time = 20
CapybaraDefaultMaxWaitTime = 60

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end


RSpec.configure do |config|
  config.include Capybara::DSL

  config.before(:suite) do |example|
    raise "Please specify KLARNA_API_KEY=xyz KLARNA_API_SECRET=XYZ in your environment variables." if !ENV['KLARNA_API_KEY'].present? || !ENV['KLARNA_API_SECRET'].present?

    if Spree::PaymentMethod.where(type: 'Spree::Gateway::KlarnaCredit').none?
      Spree::PaymentMethod.create(
        name: "Klarna Credit",
        type: 'Spree::Gateway::KlarnaCredit',
        preferences: {
          server: "test",
          test_mode: true,
          api_key: ENV['KLARNA_API_KEY'],
          api_secret: ENV['KLARNA_API_SECRET'],
          country: "us"
        })
      Spree::PaymentMethod.create(
        name: "Wrong Klarna",
        type: 'Spree::Gateway::KlarnaCredit',
        preferences: {
          server: "test",
          test_mode: true,
          api_key: 'wrong_key',
          api_secret: ENV['KLARNA_API_SECRET'],
          country: "us"
        })
    end

    if config.inclusion_filter.rules.has_key?(:bdd)
      Spree::Store.current.update_attributes(url: "http://#{Spree::Store.current.url}") unless Spree::Store.current.url.match(/http/)
    end
  end
  config.before(:each) do |example|
    Capybara.current_driver = :selenium
  end

  config.append_after(:each) do |example|
    if example.metadata[:js]
      Capybara.use_default_driver
    end
  end
end
