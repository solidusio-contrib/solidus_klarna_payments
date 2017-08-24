$store_id = ENV['STORE'] || 'us'

require 'spec_helper'

require 'capybara/rspec'
require 'capybara/rails'
require 'site_prism'

require 'config/capybara_features'
require 'config/payment_methods'
require 'config/store_currencies'

require 'support/drivers'
require 'support/wait_for_ajax'
require 'support/shared_contexts/ordering_with_klarna'


RSpec.configure do |config|
  config.include Capybara::DSL

  if config.inclusion_filter.rules.has_key?(:bdd)
    store = $store_id.downcase.to_sym
    config.filter_run_excluding only: lambda {|v| !Array(v).include?(store) }
    config.filter_run_excluding except: lambda {|v| Array(v).include?(store) }
    if KlarnaGateway.up_to_solidus?('1.5.0')
      Spree::Store.current.update_attributes(url: "http://#{Spree::Store.current.url}") unless Spree::Store.current.url && Spree::Store.current.url.match(/http/)
    else
      Spree::Store.default.update_attributes(url: "http://#{Spree::Store.default.url}") unless Spree::Store.default.url && Spree::Store.default.url.match(/http/)
    end
  end

  config.before(:each) do |example|
    Capybara.reset_sessions!
    @testing_data = TestData.new($store_id)
    Capybara.current_driver = :selenium_chrome
  end

  config.append_after(:each) do |example|
    if example.metadata[:js]
      Capybara.use_default_driver
    end
  end
end
