# frozen_string_literal: true

require 'vcr'
require 'webmock'

VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.filter_sensitive_data('<ENCODED_AUTH_HEADER>') do
    Base64.strict_encode64("#{ENV.fetch('KLARNA_API_KEY',
      'KLARNA_DEFAULT_KEY')}:#{ENV.fetch('KLARNA_API_SECRET', 'KLARNA_DEFAULT_SECRET')}")
  end
end
