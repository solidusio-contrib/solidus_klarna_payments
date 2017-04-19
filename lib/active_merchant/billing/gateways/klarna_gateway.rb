require 'activemerchant'
require 'klarna'

module ActiveMerchant
  module Billing
    class KlarnaGateway < Gateway
      def initialize(options={})
        @options = options

        Klarna.configure do |config|
          if @options[:api_secret].blank? || @options[:api_key].blank?
            raise ::KlarnaGateway::InvalidConfiguration, "Missing mandatory API credentials"
          end
          config.environment = @options[:test_mode] ? 'test' : 'production'
          config.country = @options[:country]
          config.api_key =  @options[:api_key]
          config.api_secret = @options[:api_secret]
          config.user_agent = "Klarna Solidus Gateway/#{::KlarnaGateway::VERSION} Solidus/#{::Spree.solidus_version} Rails/#{::Rails.version}"
        end
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
        auth_response = authorize(amount, payment_source, options)
        if auth_response.success?
          capture(amount, payment_source.order_id, options)
        else
          auth_response
        end
      end

      def authorize(amount, payment_source, options={})
        # TODO: check if we get a better handle for the order
        order = Spree::Order.find_by(number: options[:order_id].split("-").first)
        region = payment_source.payment_method.options[:country]
        serializer = ::KlarnaGateway::OrderSerializer.new(order, region)

        response = Klarna.client(:credit).place_order(payment_source.authorization_token, serializer.to_hash)
        update_payment_source_from_authorization(payment_source, response, order)
        update_order(response, order)

        if response.success?
          ActiveMerchant::Billing::Response.new(
            true,
            "Placed order #{order.number} Klarna id: #{payment_source.order_id}",
            response.body,
            {
              authorization: response.order_id,
              fraud_review: payment_source.fraud_status
            }
          )
        else
          ActiveMerchant::Billing::Response.new(
            false,
            readable_error(response),
            response.body,
            {
              error_code: response.error_code
            }
          )
        end
      end

      def capture(amount, order_id, options={})
        response = Klarna.client.capture(order_id, {captured_amount: amount, shipping_info: options[:shipping_info]})

        if response.success?
          capture_id = response['Capture-ID']
          payment_source = Spree::KlarnaCreditPayment.find_by(order_id: order_id)
          update_payment_source!(payment_source, order_id, capture_id: capture_id)
          ActiveMerchant::Billing::Response.new(
            true,
            "Captured order with Klarna id: '#{order_id}' Capture id: '#{capture_id}'",
            response.body || {},
            {
              authorization: order_id,
              fraud_review: payment_source.fraud_status
            }
          )
        else
          ActiveMerchant::Billing::Response.new(
            false,
            readable_error(response),
            response.body || {},
            {
              error_code: response.error_code
            }
          )
        end
      end

      def refund(amount, order_id, options={})
        # Get the refunded line items for better customer communications
        line_items = []
        if options[:originator].present?
          region = options[:originator].try(:payment).payment_method.options[:country]
          line_items = Array(options[:originator].try(:reimbursement).try(:return_items)).map do |item|
            ::KlarnaGateway::LineItemSerializer.new(item.inventory_unit.line_item, region)
          end
        end
        response = Klarna.client(:refund).create(order_id, {refunded_amount: amount, order_lines: line_items})

        if response.success?
          update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
          ActiveMerchant::Billing::Response.new(
            true,
            "Refunded order with Klarna id: #{order_id}",
            response.body || {},
            {
              authorization: response['Refund-ID']
            }
          )
        else
          ActiveMerchant::Billing::Response.new(
            false,
            'Klarna Gateway: There was an error refunding this refund.',
            response.body || {},
            { error_code: response.error_code }
          )
        end
      end

      alias_method :credit, :refund

      def get(order_id)
        Klarna.client.get(order_id)
      end

      def acknowledge(order_id)
        response = Klarna.client.acknowledge(order_id)

        if response.success?
          update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
          ActiveMerchant::Billing::Response.new(
            true,
            "Extended Period for order with Klarna id: #{order_id}",
            response.body || {}
          )
        else
          ActiveMerchant::Billing::Response.new(
            false,
            'Klarna Gateway: There was an error processing this acknowledge.',
            response.body || {},
            {
              error_code: response.error_code
            }
          )
        end
      end

      def extend_period(order_id)
        response = Klarna.client.extend(order_id)

        if response.success?
          update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
          ActiveMerchant::Billing::Response.new(
            true,
            "Extended Period for order with Klarna id: #{order_id}",
            response.body || {}
          )
        else
          ActiveMerchant::Billing::Response.new(
            false,
            'Klarna Gateway: There was an error processing this period extension.',
            response.body || {},
            {
              error_code: response.error_code
            }
          )
        end
      end

      def release(order_id)
        response = Klarna.client.release(order_id)

        if response.success?
          update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
          ActiveMerchant::Billing::Response.new(
            true,
            "Released reamining amount for order with Klarna id: #{order_id}",
            response.body || {},
            {
              authorization: order_id
            }
          )
        else
          ActiveMerchant::Billing::Response.new(
            false,
            'Klarna Gateway: There was an error processing this release.',
            response.body || {},
            {
              error_code: response.error_code
            }
          )
        end
      end

      def cancel(order_id)
        response = Klarna.client.cancel(order_id)

        if response.success?
          update_payment_source!(Spree::KlarnaCreditPayment.find_by(order_id: order_id), order_id)
          ActiveMerchant::Billing::Response.new(
            true,
            "Cancelled order with Klarna id: #{order_id}",
            response.body || {},
            {
              authorization: order_id
            }
          )
        else
          ActiveMerchant::Billing::Response.new(
            false,
            'Klarna Gateway: There was an error cancelling this payment.',
            response.body || {},
            { error_code: response.error_code }
          )
        end
      end

      def shipping_info(order_id, capture_id, shipping_info)
        response = Klarna.client(:capture).shipping_info(
          order_id,
          capture_id,
          shipping_info
        )
        if response.success?
          ActiveMerchant::Billing::Response.new(
            true,
            "Updated shipment info for order: #{order_id}, capture: #{capture_id}",
            response.body || {},
          )
        else
          ActiveMerchant::Billing::Response.new(
            false,
            "Cannot update the shipment info for order: #{order_id} capture: #{capture_id}",
            response.body || {},
            { error_code: response.error_code }
          )
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

      def update_payment_source(payment_source, klarna_order_id, attributes = {})
        get(klarna_order_id).tap do |klarna_order|
          payment_source.status = klarna_order.status
          payment_source.fraud_status = klarna_order.fraud_status
          payment_source.expires_at = DateTime.parse(klarna_order.expires_at)
          payment_source.assign_attributes(attributes)
        end
        payment_source
      end

      def update_payment_source!(payment_source, klarna_order_id, attributes = {})
        update_payment_source(payment_source, klarna_order_id, attributes).tap do |order|
          order.save!
          order
        end
      end

      def readable_error(response)
        I18n.t(response.error_code.to_s.downcase, scope: "klarna.gateway_errors", default: "Klarna Gateway: Please check your payment method.")
      end
    end
  end
end
