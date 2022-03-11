# frozen_string_literal: true

module SolidusKlarnaPayments
  class CreateOrUpdateKlarnaSessionService < BaseService
    class CreateOrUpdateKlarnaSessionError < StandardError; end

    def initialize(order:, klarna_payment_method:, store:)
      @order = order
      @klarna_payment_method = klarna_payment_method
      @store = store

      super()
    end

    def call
      if order.klarna_client_token.nil?
        create_session
      else
        update_session
      end

      return order.klarna_client_token if order.reload.klarna_client_token.present?

      raise CreateOrUpdateKlarnaSessionError, "Could not create or update Klarna session for order '#{order.number}'."
    end

    private

    def create_session
      klarna_payment_method
        .gateway
        .create_session(order_params.except(:billing_address))
        .tap do |response|
          raise CreateOrUpdateKlarnaSessionError, response.inspect unless response.success?

          order.update_klarna_session(
            session_id: response.session_id,
            client_token: response.client_token
          )
        end
    end

    def update_session
      klarna_payment_method
        .gateway
        .update_session(
          order.klarna_session_id,
          order_params.except(:billing_address)
        )
        .tap do |response|
          raise CreateOrUpdateKlarnaSessionError, response.inspect unless response.success?

          order.update_klarna_session_time
        end
    end

    def order_params
      SolidusKlarnaPayments::CreateSessionOrderPresenter.new(
        order: order,
        klarna_payment_method: klarna_payment_method,
        store: store,
        skip_personal_data: true
      ).to_hash
    end

    attr_reader :order, :klarna_payment_method, :store
  end
end
