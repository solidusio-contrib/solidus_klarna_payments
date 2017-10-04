$store_id = ENV['STORE'] || 'us'
require 'spec_helper'

require 'capybara/rspec'
require 'capybara/rails'
require 'site_prism'


require 'support/drivers'
require 'support/wait_for_ajax'
require 'support/shared_contexts/ordering_with_klarna'
require 'support/responsive_helpers'

require 'config/capybara_features'
require 'config/payment_methods'
require 'config/store_currencies'

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include ResponsiveHelpers

  if config.inclusion_filter.rules.has_key?(:bdd)
    store = $store_id.downcase.to_sym

    if KlarnaGateway.is_solidus?
      config.filter_run_excluding framework: :spree
    else
      config.filter_run_excluding framework: :solidus
    end

    config.filter_run_excluding only: lambda {|v| !Array(v).include?(store) }
    config.filter_run_excluding except: lambda {|v| Array(v).include?(store) }
  end

  config.before(:each) do |example|
    @testing_data = TestData.new($store_id)
    Capybara.current_driver = :selenium_chrome
    resize_window_desktop_store
  end

  config.append_after(:each) do |example|
    if example.metadata[:js]
      Capybara.use_default_driver
    end
  end
end
