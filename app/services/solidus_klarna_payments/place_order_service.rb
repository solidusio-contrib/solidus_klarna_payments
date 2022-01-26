# frozen_string_literal: true

module SolidusKlarnaPayments
  class PlaceOrderService < BaseService
    def initialize(order:, payment_source:)
      @order = order
      @payment_source = payment_source
      @customer_token_payment = payment_source.customer_token.present?

      super()
    end

    def call
      client
    end

    private

    def client
      Klarna
        .client(client_name)
        .place_order(
          token,
          order_params
        )
    end

    def client_name
      customer_token_payment ? :customer_token : :payment
    end

    def token
      customer_token_payment ? payment_source.customer_token : payment_source.authorization_token
    end

    def order_params
      SolidusKlarnaPayments::OrderSerializer.new(order, region).to_hash
    end

    def region
      @region ||= payment_method.preferred_country
    end

    def payment_method
      @payment_method ||= payment_source.payment_method
    end

    attr_reader :order, :payment_source, :customer_token_payment
  end
end
