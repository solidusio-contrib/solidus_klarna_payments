# frozen_string_literal: true

require 'spree/core'
require 'solidus_klarna_payments'

module SolidusKlarnaPayments
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_klarna_payments'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree.solidus_klarna_payments.payment_methods', after: 'spree.register.payment_methods' do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::KlarnaCredit
    end

    config.to_prepare do
      ::Spree::PermittedAttributes.source_attributes << :authorization_token
    end
  end
end
