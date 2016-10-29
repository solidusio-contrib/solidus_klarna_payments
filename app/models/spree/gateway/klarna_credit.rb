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
        Spree::KlarnaCreditPayment
      end

      def source_required?
        true
      end

      def credit_card?
        false
      end

      def payment_profiles_supported?
        false
      end
    end
  end
end
