require 'database_cleaner'

RSpec.configure do |config|
  unless config.inclusion_filter.rules.has_key?(:bdd)
    # TDD exectution
    config.before :suite do
      DatabaseCleaner.clean_with :truncation
    end

    config.before do
      DatabaseCleaner.strategy = RSpec.current_example.metadata[:js] ? :truncation : :transaction
      DatabaseCleaner.start
    end

    config.after do
      DatabaseCleaner.clean
    end
  end
end
