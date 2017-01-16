require 'spec_helper'

require 'capybara/rspec'
require 'capybara/rails'
require 'support/drivers'
require 'support/wait_for_ajax'
require 'support/shared_contexts/ordering_with_klarna'

# Configure Capybara expected host
$data = TestData.new(ENV['STORE'])
Capybara.app_host = $data.host

Capybara.default_selector = :css
Capybara.default_max_wait_time = 20
CapybaraDefaultMaxWaitTime = 60

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end


RSpec.configure do |config|
  config.include Capybara::DSL

  config.before(:each) do |example|
    Capybara.current_driver = :selenium
  end

  config.append_after(:each) do |example|
    if example.metadata[:js]
      Capybara.use_default_driver
    end
  end
end
