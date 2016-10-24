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
    end
  end
end
