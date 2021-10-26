# frozen_string_literal: true

module SolidusKlarnaPayments
  class ValidateKlarnaCredentialsService < BaseService
    class MissingCredentialsError < StandardError; end

    def initialize(api_key:, api_secret:, test_mode:, country:)
      @api_key = api_key
      @api_secret = api_secret
      @test_mode = test_mode
      @country = country

      raise MissingCredentialsError if missing_credentials?

      configure_klarna

      super()
    end

    def call
      response = Klarna.client(:payment).create_session({})
      response.http_response.code != '401'
    end

    private

    def missing_credentials?
      api_key.blank? || api_secret.blank?
    end

    def configure_klarna
      Klarna.configure do |config|
        config.environment = test_mode == '0' ? 'production' : 'test'
        config.country = country
        config.api_key =  api_key
        config.api_secret = api_secret
        config.user_agent = "Klarna Solidus Gateway/#{::SolidusKlarnaPayments::VERSION} Solidus/#{::Spree.solidus_version} Rails/#{::Rails.version}"
      end
    end

    attr_reader :api_key, :api_secret, :test_mode, :country
  end
end
