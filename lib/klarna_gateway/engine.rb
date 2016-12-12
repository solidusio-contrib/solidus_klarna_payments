module KlarnaGateway
  class Engine < Rails::Engine
    engine_name 'klarna_gateway'

    initializer "spree.klarna_gateway.payment_methods", :after => "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::Gateway::KlarnaCredit
    end

    config.to_prepare do
      require 'httplog' if Rails.env.development?
      Spree::PermittedAttributes.source_attributes << "authorization_token"
    end

    config.after_initialize do
      if defined?(Spree::Admin)
        Spree::Admin::OrdersController.include(KlarnaGateway::Admin::OrdersController)
        Spree::Admin::PaymentsController.include(KlarnaGateway::Admin::PaymentsController)
      end
      Spree::CheckoutController.include(KlarnaGateway::SessionController)
      Spree::CheckoutController.include(KlarnaGateway::CheckoutController)
      Spree::Order.include(KlarnaGateway::Order)
      Spree::Payment.include(KlarnaGateway::Payment)
    end
  end
end
