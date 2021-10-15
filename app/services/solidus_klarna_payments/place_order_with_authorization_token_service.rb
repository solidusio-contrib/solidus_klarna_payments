# frozen_string_literal: true

module SolidusKlarnaPayments
  class PlaceOrderWithAuthorizationTokenService < BaseService
    def initialize(order:, payment_source:)
      @order = order
      @payment_source = payment_source

      super()
    end

    def call
      Klarna
        .client(:payment)
        .place_order(
          payment_source.authorization_token,
          order_params
        )
    end

    private

    def order_params
      SolidusKlarnaPayments::OrderSerializer.new(order, region).to_hash
    end

    def region
      @region ||= payment_method.preferred_country
    end

    def payment_method
      @payment_method ||= payment_source.payment_method
    end

    attr_reader :order, :payment_source
  end
end
