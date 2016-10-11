require 'activemerchant'

module ActiveMerchant
  module Billing
    class KlarnaGateway < Gateway
      def initialize(options={})
        super
      end

      def purchase(amount, payment, options = {})
      end

      def authorize(amount, payment, options={})
      end

      def capture(amount, authorization, options={})
      end

      def refund(amount, authorization, options={})
      end

      def void(authorization, options={})
      end

      def credit(amount, payment, options={})
      end

      def verify(credit_card, options = {})
      end

      def store(credit_card, options = {})
      end
    end
  end
end
