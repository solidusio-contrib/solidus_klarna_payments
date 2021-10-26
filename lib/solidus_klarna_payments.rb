# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

require 'solidus_klarna_payments/version'
require 'solidus_klarna_payments/engine'
require 'solidus_klarna_payments/exceptions'
require 'solidus_klarna_payments/configuration'

require 'active_merchant/billing/klarna_gateway'

module SolidusKlarnaPayments
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    delegate :store_customer_token_service_class, to: :configuration
    delegate :retrieve_customer_token_service_class, to: :configuration
  end
end
