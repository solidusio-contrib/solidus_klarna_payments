Capybara.default_selector = :css
Capybara.default_max_wait_time = 20
CapybaraExtraWaitTime = 30

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, clear_local_storage: true, clear_session_storage: true)
end

Capybara.raise_server_errors = false
