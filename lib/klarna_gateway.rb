require "spree_core"
require "spree_frontend"
require "klarna_gateway/version"
require "active_merchant/billing/gateways/klarna_gateway"
require "klarna_gateway/engine"

module KlarnaGateway
  module ControllerSession
    KLARNA_SESSION_LIFETIME = 60.minutes

    def klarna_session
      order = Spree::OrderSerializer.new(@order, klarna_payment_method.preferences[:country])

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
        end
        render json: {token: response.client_token}
      end
    end

    def self.included(base)
      base.skip_action_callback(:ensure_valid_state)
    end

    private

    # TODO: hand over the payment method id in case there's more than one Klarna Credit
    def klarna_payment_method
      @klarna_payment_method ||= Spree::PaymentMethod.where(type: 'Spree::Gateway::KlarnaCredit').last
    end

    def klarna_current_session?
      session.has_key?(:klarna_credit_session_created) && session[:klarna_credit_session_created] > KLARNA_SESSION_LIFETIME.ago
    end
  end
end
