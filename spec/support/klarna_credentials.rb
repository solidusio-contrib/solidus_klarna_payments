# frozen_string_literal: true

module TestHelpers
  module CredentialsHelper
    def klarna_credentials
      {
        key: ENV['SOLIDUS_KLARNA_PAYMENTS_API_KEY'],
        secret: ENV['SOLIDUS_KLARNA_PAYMENTS_API_SECRET'],
      }
    end
  end
end

RSpec.configure do |config|
  config.include TestHelpers::CredentialsHelper, type: :request
end
