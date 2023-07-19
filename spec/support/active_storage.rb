# frozen_string_literal: true

RSpec.configure do |config|
  if defined?(ActiveStorage::Current)
    config.before(:all) do
      host = 'http://www.example.com'
      if Rails.gem_version >= Gem::Version.new(7)
        ActiveStorage::Current.url_options = { host: host }
      else
        ActiveStorage::Current.host = host
      end
    end
  end
end
