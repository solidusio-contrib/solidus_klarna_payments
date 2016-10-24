require_dependency 'activemerchant'
require_dependency 'klarna'

module ActiveMerchant
  module Billing
    class KlarnaGateway < Gateway
      def initialize(options={})
        @config = config

        Klarna.configure do |config|
          config.environment = :test
          config.country = ENV.fetch("KLARNA_REGION") { :us }.to_sym
          config.api_key = ENV["KLARNA_API_KEY"]
          config.api_secret = ENV["KLARNA_API_SECRET"]
        end

        @config[:logger] = ::Logger.new(STDOUT)
        @config[:logger].level = ::Logger::WARN
      end

      def purchase(amount, payment, options = {})
        binding.pry
      end

      def authorize(amount, payment, options={})
        binding.pry
        Klarna.client.create_session(order)
      end

      def capture(amount, authorization, options={})
        binding.pry
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


# 1 Spree
# 2  Gateway (Connect the cables)
# 3    ActiveMerchant (Abstraction)
# 4      KlarnaSDK (Doing/Done) <<Pure Ruby>>


