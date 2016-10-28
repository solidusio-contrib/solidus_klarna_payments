require_dependency 'activemerchant'

require_dependency 'klarna'

module ActiveMerchant
  module Billing
    class KlarnaGateway < Gateway
      def initialize(options={})
        @options = options

        Klarna.configure do |config|
          config.environment = @options[:server]
          config.country = @options[:country]
          config.api_key =  @options[:api_key]
          config.api_secret = @options[:api_secret]
        end

        @options[:logger] = ::Logger.new(STDOUT)
        @options[:logger].level = ::Logger::WARN
      end

      def create_session(order)
        Klarna.client.create_session(order)
      end

      def purchase(amount, payment, options = {})
        binding.pry
      end

      def authorize(amount, payment, options={})
        binding.pry
        # Klarna.client.create_session(options)
        # <= token
      end

      def capture(amount, authorization, options={})
        binding.pry
        # Klarna.client.authorize(options)
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
