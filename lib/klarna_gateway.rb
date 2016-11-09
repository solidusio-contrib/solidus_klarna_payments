require "spree_core"
require "spree_frontend"
require "klarna_gateway/version"
require "active_merchant/billing/gateways/klarna_gateway"
require "klarna_gateway/engine"

module KlarnaGateway
  module ControllerSession
    def klarna_session
      klarna = Spree::PaymentMethod.where(type: 'Spree::Gateway::KlarnaCredit').last
      order = Spree::OrderSerializer.new(@order, klarna.preferences[:country])
      response = klarna.provider.create_session(order)
      session[:token] = response.client_token
      render json: {token: response.client_token}
    end

    def self.included(base)
      base.skip_action_callback(:ensure_valid_state)
    end
  end
end
