require "spree_core"
require "spree_frontend"
require "klarna_gateway/version"
require "active_merchant/billing/gateways/klarna_gateway"
require "klarna_gateway/engine"

module KlarnaGateway
  module ControllerSession
    KLARNA_SESSION_LIFETIME = 60.minutes

    def klarna_session
      Spree::OrderUpdater.new(@order).update
      order = Spree::OrderSerializer.new(@order.reload, klarna_payment_method.preferences[:country])
      order.options = klarna_options
      order.design = klarna_payment_method.preferences[:design]

      # If the session is fresh: update the session and return the token
      if klarna_current_session?
        klarna_payment_method.provider.update_session(session[:klarna_credit_session_id], order)
        render json: {token: session[:klarna_credit_client_token]}
      else
        # else create a new session
        response = klarna_payment_method.provider.create_session(order)
        if response.success?
          session[:klarna_credit_client_token] = response.client_token
          session[:klarna_credit_session_id] = response.session_id
          session[:klarna_credit_session_created] = Time.current
          session[:klarna_credit_order_id] = @order.id
        end
        render json: {token: response.client_token}
      end
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

    def klarna_current_session?
      session.has_key?(:klarna_credit_session_created) &&
        session[:klarna_credit_session_created] > KLARNA_SESSION_LIFETIME.ago &&
        session[:klarna_credit_order_id] == @order.id
    end
  end
end
