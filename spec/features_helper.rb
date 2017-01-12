require 'spec_helper'

require 'capybara/rspec'
require 'capybara/rails'
require 'support/drivers'
require 'support/wait_for_ajax'


# Configure Capybara expected host
Capybara.app_host = 'https://klarna-solidus-demo.herokuapp.com'
Capybara.default_selector = :css
Capybara.default_max_wait_time = 60

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end


RSpec.configure do |config|
  config.include Capybara::DSL

  config.before(:each) do |example|
    # default_url_options[:host] = 'https://klarna-solidus-demo.herokuapp.com'
    Capybara.default_wait_time = 10 # seconds
    Capybara.current_driver = :selenium
  end

  config.append_after(:each) do |example|
    if example.metadata[:js]
      Capybara.use_default_driver
    end
  end
end
