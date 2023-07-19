# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

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
      app.reloader.to_prepare do
        app.config.spree.payment_methods << ::Spree::PaymentMethod::KlarnaCredit
      end
    end

    config.to_prepare do
      ::Spree::PermittedAttributes.source_attributes << :authorization_token
    end
  end
end
