Capybara.default_selector = :css
Capybara.default_max_wait_time = 20
CapybaraDefaultMaxWaitTime = 60
CapybaraExtraWaitTime = 90

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, clear_local_storage: true, clear_session_storage: true)
end

Capybara.raise_server_errors = false
