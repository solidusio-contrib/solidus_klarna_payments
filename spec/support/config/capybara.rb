# frozen_string_literal: true

Capybara.register_driver :apparition_without_js_errors do |app|
  Capybara::Apparition::Driver.new(app, js_errors: true)
end

Capybara.save_path = '/tmp/capybara-screenshots'
