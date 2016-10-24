require "klarna_gateway/version"
require "active_merchant/billing/gateways/klarna_gateway"

module KlarnaGateway
  class Engine < Rails::Engine
    engine_name 'klarna_gateway'

    initializer "spree.klarna_gateway.payment_methods", :after => "spree.register.payment_methods" do |app|
        app.config.spree.payment_methods << Spree::Gateway::KlarnaCredit
    end
  end
end
