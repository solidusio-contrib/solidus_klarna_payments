require "spree_core"
require "spree_frontend"
require "klarna_gateway/version"
require "active_merchant/billing/gateways/klarna_gateway"
require "klarna_gateway/engine"
require "klarna_gateway/order"

module KlarnaGateway
  module ControllerSession
    KLARNA_SESSION_LIFETIME = 60.minutes

    def klarna_session
      @order.state = "payment"
      order = Spree::OrderSerializer.new(@order.reload, klarna_payment_method.preferences[:country])
      order.options = klarna_options
      order.design = klarna_payment_method.preferences[:design]

      if @order.klarna_session_expired?
        klarna_payment_method.provider.create_session(order).tap do |response|
          @order.update_klarna_session(
            session_id: response.session_id,
            client_token: response.client_token
            ) if response.success?
        end
      else
        klarna_payment_method.provider.update_session(@order.klarna_session_id, order).tap do |response|
          @order.update_klarna_session_time() if response.success?
        end
      end

      render json: {token: @order.reload.klarna_client_token}
    end

    def self.included(base)
      # TODO: only on klarna_session (maybe even not there)
      base.skip_action_callback(:ensure_valid_state)
    end

    private

    # TODO: hand over the payment method id in case there's more than one Klarna Credit
    def klarna_payment_method
      @klarna_payment_method ||= Spree::PaymentMethod.where(type: 'Spree::Gateway::KlarnaCredit').last
    end

    def klarna_options
      klarna_payment_method.preferences.select do |key, value|
        key.to_s.start_with?("color_", "radius_") && value.present?
      end
    end
  end
end
