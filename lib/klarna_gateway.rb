require "klarna_gateway/version"
require "active_merchant/billing/gateways/klarna_gateway"

module KlarnaGateway

  module ControllerSession
    def klarna_session
      binding.pry

      klarna = Spree::PaymentMethod.where(type: 'Spree::Gateway::KlarnaCredit').last
      response = klarna.authorize(@order.amount, nil, Spree::OrderSerializer.new(order).to_hash)

      session[:token] = response.client_token
      json token: response.client_token
    end

  end

  class Engine < Rails::Engine
    engine_name 'klarna_gateway'

    initializer "spree.klarna_gateway.payment_methods", :after => "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::Gateway::KlarnaCredit
    end

    config.to_prepare do
      Spree::CheckoutController.include KlarnaGateway::ControllerSession
    end
  end
end
