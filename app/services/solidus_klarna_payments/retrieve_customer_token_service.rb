# frozen_string_literal: true

module SolidusKlarnaPayments
  class RetrieveCustomerTokenService < BaseService
    def initialize(order:)
      @order = order

      super()
    end

    def call
      order&.user&.klarna_customer_token
    end

    private

    attr_reader :order
  end
end
