module Spree
  class Gateway
    class KlarnaCredit < Gateway
      preference :api_key, :string
      preference :api_secret, :string
      preference :country, :string
      preference :environment, :string

      def provider_class
        ActiveMerchant::Billing::KlarnaGateway
      end

      def method_type
        'klarna_credit'
      end

      def payment_source_class
        Spree::KlarnaPayment
      end

    end
  end
end
