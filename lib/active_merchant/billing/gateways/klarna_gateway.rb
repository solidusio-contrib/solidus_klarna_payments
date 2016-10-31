require 'activemerchant'
require 'klarna'

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

      # There is only :klarna_credit
      def self.supports?(brand)
        true
      end

      def create_session(order)
        Klarna.client.create_session(order)
      end

      def purchase(amount, payment, options = {})
        auth_response = authorize(amount, payment, options)
        if auth_response.success?
          capture(amount, auth_response.order_id, options)
        else
          auth_response
        end
      end

      def authorize(amount, payment, options={})
        # TODO: check if we get a better handle for the order
        order = Spree::Order.find_by(number: options[:order_id].split("-").first)

        response = Klarna.client.place_order(payment.authorization_token, Spree::OrderSerializer.new(order))
        Response.new(response.success?, "Place order", {}, {authorization: response.order_id})
      end

      def capture(amount, order_id, options={})
        response = Klarna.client.capture_order(order_id, {captured_amount: amount})
        Response.new(response.success?, "Capture")
      end

      def refund(amount, order_id, options={})
        response = Klarna.client.refund_order(order_id, {refunded_amount: amount})
        Response.new(response.success?, "Refund")
      end
      alias_method :credit, :refund
    end
  end
end
