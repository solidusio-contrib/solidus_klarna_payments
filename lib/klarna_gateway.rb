require "klarna_gateway/version"
require "active_merchant/billing/gateways/klarna_gateway"

module KlarnaGateway

  module ControllerSession
    def klarna_session
      klarna = Spree::PaymentMethod.where(type: 'Spree::Gateway::KlarnaCredit').last
      response = klarna.provider.create_session(Spree::OrderSerializer.new(@order))
      session[:token] = response.client_token
      render json: {token: response.client_token}
    end

    def self.included(base)
      base.skip_action_callback(:ensure_valid_state)
    end
  end

  class Engine < Rails::Engine
    engine_name 'klarna_gateway'

    initializer "spree.klarna_gateway.payment_methods", :after => "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::Gateway::KlarnaCredit
    end

    config.to_prepare do
      require 'httplog' if Rails.env.development?
      Spree::CheckoutController.include KlarnaGateway::ControllerSession
    end
  end
end
