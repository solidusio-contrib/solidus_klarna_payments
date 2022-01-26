# frozen_string_literal: true

module SolidusKlarnaPayments
  class CreateCustomerTokenService < BaseService
    def initialize(order:, authorization_token:, region:)
      @order = order
      @authorization_token = authorization_token
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

    attr_reader :order, :region, :authorization_token

    def customer_token_params
      SolidusKlarnaPayments::CustomerTokenSerializer.new(
        order: order,
        description: 'Customer token',
        region: region
      ).to_hash
    end
  end
end
