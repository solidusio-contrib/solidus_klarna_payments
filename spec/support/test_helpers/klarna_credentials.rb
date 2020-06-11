# frozen_string_literal: true

module TestHelpers
  module CredentialsHelper
    def klarna_credentials
      {
        key: 'PN02334_81166e4b64df',
        secret: 'rp5RInD6lL1b53TE',
      }
    end
  end
end

RSpec.configure do |config|
  config.include TestHelpers::CredentialsHelper
end
