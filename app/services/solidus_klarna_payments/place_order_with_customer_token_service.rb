# frozen_string_literal: true

module SolidusKlarnaPayments
  class PlaceOrderWithCustomerTokenService < BaseService
    class FetchCustomerTokenError < StandardError; end

    def initialize(order:, payment_source:)
      @order = order
      @payment_source = payment_source

      super()
    end

    def call
      Klarna
        .client(:customer_token)
        .place_order(
          customer_token,
          order_params
        )
    rescue FetchCustomerTokenError
      @customer_token_response
    end

    private

    def customer_token
      customer_token = SolidusKlarnaPayments
                       .configuration
                       .retrieve_customer_token_service_class
                       .call(order: order)

      customer_token = fetch_customer_token if customer_token.blank?

      raise FetchCustomerTokenError if customer_token.blank?

      customer_token
    end

    def fetch_customer_token
      @customer_token_response = Klarna
                                 .client(:payment)
                                 .customer_token(
                                   payment_source.authorization_token,
                                   customer_token_params
                                 )

      customer_token = begin
        @customer_token_response.token_id
      rescue NoMethodError
        nil
      end

      return customer_token unless customer_token


      customer_token
    end

    def customer_token_params
      SolidusKlarnaPayments::CustomerTokenSerializer.new(
        order: order,
        description: 'Customer token',
        region: region
      ).to_hash
    end

    def order_params
      SolidusKlarnaPayments::OrderSerializer.new(order, region).to_hash
    end

    def region
      @region ||= payment_method.preferred_country
    end

    def payment_method
      @payment_method ||= payment_source&.payment_method || ::Spree::PaymentMethod::KlarnaCredit.active.last
    end

    attr_reader :order, :payment_source
  end
end
