require "spree_core"
require "spree_frontend"
require "klarna_gateway/version"
require "active_merchant/billing/gateways/klarna_gateway"
require "klarna_gateway/engine"
require "byebug"

module KlarnaGateway
  module ControllerSession
    KLARNA_SESSION_LIFETIME = 60.minutes

    def klarna_session
      byebug
      if session.has_key?(:klarna_credit_session_created) && session[:klarna_credit_session_created] > KLARNA_SESSION_LIFETIME.ago
        # TODO: update session
        render json: {token: session[:klarna_credit_session_token]}
      else
        klarna = Spree::PaymentMethod.where(type: 'Spree::Gateway::KlarnaCredit').last
        order = Spree::OrderSerializer.new(@order, klarna.preferences[:country])
        response = klarna.provider.create_session(order)
        if response.success?
          session[:klarna_credit_session_token] = response.client_token
          session[:klarna_credit_session_created] = Time.current
        end
        render json: {token: response.client_token}
      end
    end

    def self.included(base)
      base.skip_action_callback(:ensure_valid_state)
    end
  end
end
