Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, timeout: 1.minute, phantomjs_options: ['--load-images=no'])
end
Capybara.javascript_driver = :poltergeist

