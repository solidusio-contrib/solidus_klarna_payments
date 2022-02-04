# frozen_string_literal: true

module SolidusKlarnaPayments
  class CreateCustomerTokenService < BaseService
    def initialize(email:, address:, authorization_token:, currency:, region:)
      @email = email
      @address = address
      @authorization_token = authorization_token
      @currency = currency
      @region = region

      super()
    end

    def call
      @customer_token_response = Klarna
                                 .client(:payment)
                                 .customer_token(
                                   authorization_token,
                                   customer_token_params
                                 )

      @customer_token_response.token_id
    rescue NoMethodError
      nil
    end

    private

    attr_reader :email, :address, :currency, :region, :authorization_token

    def customer_token_params
      SolidusKlarnaPayments::CustomerTokenSerializer.new(
        email: email,
        address: address,
        description: 'Customer token',
        currency: currency,
        region: region
      ).to_hash
    end
  end
end
