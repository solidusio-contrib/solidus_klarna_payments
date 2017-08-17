Capybara.default_selector = :css
Capybara.default_max_wait_time = 20
CapybaraDefaultMaxWaitTime = 60

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.raise_server_errors = false
