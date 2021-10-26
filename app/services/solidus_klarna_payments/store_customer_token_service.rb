# frozen_string_literal: true

module SolidusKlarnaPayments
  class StoreCustomerTokenService < BaseService
    def initialize(order:, customer_token:)
      @user = order&.user
      @customer_token = customer_token

      super()
    end

    def call
      return false unless user

      user.update(klarna_customer_token: customer_token)
    end

    private

    attr_reader :user, :customer_token
  end
end
