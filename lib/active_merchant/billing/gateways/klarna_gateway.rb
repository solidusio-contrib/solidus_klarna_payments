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
        Klarna.client(:credit).create_session(order)
      end

      def update_session(session_id, order)
        Klarna.client(:credit).update_session(session_id, order)
      end

      def purchase(amount, payment_source, options = {})
        auth_response = authorize(amount, payment, options)
        if auth_response.success?
          capture(amount, auth_response.order_id, options)
        else
          auth_response
        end
      end

      def authorize(amount, payment_source, options={})
        # TODO: check if we get a better handle for the order
        order = Spree::Order.find_by(number: options[:order_id].split("-").first)
        region = payment_source.payment_method.preferences[:country]
        serializer = ::KlarnaGateway::OrderSerializer.new(order, region)

        response = Klarna.client(:credit).place_order(payment_source.authorization_token, serializer.to_hash)
        update_payment_source_from_authorization(payment_source, response, order)
        update_order(response, order)

        if response.success?
          ActiveMerchant::Billing::Response.new(true, "Placed order #{order.number} Klara id: #{payment_source.spree_order_id}", {}, authorization: response.order_id)
        else
          ActiveMerchant::Billing::Response.new(false, 'Klarna Gateway: Please check your payment method.', {}, { error_code: response.error_code, message: 'Klarna Gateway: Please check your payment method.' })
        end
      end

      def capture(amount, order_id, options={})
        response = Klarna.client.capture(order_id, {captured_amount: amount})

        if response.success?
          update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
          ActiveMerchant::Billing::Response.new(true, "Captured order #{order_id}", {})
        else
          ActiveMerchant::Billing::Response.new(false, 'Klarna Gateway: There was an error processing this payment.', {}, { error_code: response.error_code, message: response.error_message })
        end
      end

      def refund(amount, order_id, options={})
        response = Klarna.client(:refund).create(order_id, {refunded_amount: amount})

        if response.success?
          update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
          ActiveMerchant::Billing::Response.new(true, "Refund #{order_id}", {})
        else
          ActiveMerchant::Billing::Response.new(false, 'Klarna Gateway: There was an error refunding this payment.', {}, { error_code: response.error_code, message: response.error_message })
        end
      end
      alias_method :credit, :refund

      def get(order_id)
        Klarna.client.get(order_id)
      end

      def acknowledge(order_id)
        Klarna.client.acknowledge(order_id)
      end

      def extend(order_id)
        Klarna.client.extend(order_id)
      end

      def release(order_id)
        Klarna.client.release(order_id)
      end

      def cancel(order_id)
        response = Klarna.client.cancel(order_id)

        if response.success?
          update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
          ActiveMerchant::Billing::Response.new(true, "Refund #{order_id}", {})
        else
          ActiveMerchant::Billing::Response.new(false, 'Klarna Gateway: There was an error refunding this payment.', {}, { error_code: response.error_code, message: response.error_message })
        end
      end

      def get_and_update_source(order_id)
        update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
      end

      private

      def update_order(response, order)
        if response.success?
          order.update_attributes(
            klarna_order_id: response.order_id,
            klarna_order_state: response.fraud_status
          )
        else
          order.update_attributes(
            klarna_order_id: nil,
            klarna_order_state: response.error_code
          )
        end
      end

      def update_payment_source_from_authorization(payment_source, response, order)
        payment_source.spree_order_id = order.id
        payment_source.response_body = response.body
        payment_source.redirect_url = response.redirect_url if response.respond_to?(:redirect_url)

        if response.success?
          payment_source.order_id = response.order_id
          payment_source = update_payment_source(payment_source, response.order_id)
        else
          payment_source.error_code = response.error_code
          payment_source.error_messages = response.error_messages
          payment_source.correlation_id = response.correlation_id
        end

        payment_source.save!
      end

      def update_payment_source(payment_source, klarna_order_id)
        get(klarna_order_id).tap do |klarna_order|
          payment_source.status = klarna_order.status
          payment_source.fraud_status = klarna_order.fraud_status
          payment_source.expires_at = DateTime.parse(klarna_order.expires_at)
        end
        payment_source
      end

      def update_payment_source!(payment_source, klarna_order_id)
        update_payment_source(payment_source, klarna_order_id).save
      end
    end
  end
end
