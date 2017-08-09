require 'spec_helper'

require 'capybara/rspec'
require 'capybara/rails'
require 'site_prism'

require 'config/capybara_features'
require 'config/payment_methods'

require 'support/drivers'
require 'support/wait_for_ajax'
require 'support/shared_contexts/ordering_with_klarna'

# Configure Capybara expected host
$data = TestData.new(ENV['STORE'])

RSpec.configure do |config|
  config.include Capybara::DSL

  if config.inclusion_filter.rules.has_key?(:bdd)
    if KlarnaGateway.up_to_solidus?('1.5.0')
      Spree::Store.current.update_attributes(url: "http://#{Spree::Store.current.url}") unless Spree::Store.current.url && Spree::Store.current.url.match(/http/)
    else
      Spree::Store.default.update_attributes(url: "http://#{Spree::Store.default.url}") unless Spree::Store.default.url && Spree::Store.default.url.match(/http/)
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
