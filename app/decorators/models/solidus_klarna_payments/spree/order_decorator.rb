# frozen_string_literal: true

module SolidusKlarnaPayments
  module Spree
    module OrderDecorator
      KLARNA_SESSION_LIFETIME = 48.hours

      def self.prepended(base)
        base.after_commit :invalidate_klarna_session
      end

      def klarna_tokenizable?
        user.present?
      end

      def update_klarna_session(session_id: nil, client_token: nil)
        update!(
          klarna_session_id: session_id,
          klarna_client_token: client_token,
          klarna_session_expires_at: DateTime.now + KLARNA_SESSION_LIFETIME
        )
      end

      def update_klarna_session_time
        update!(
          klarna_session_expires_at: DateTime.now + KLARNA_SESSION_LIFETIME
        )
      end

      def klarna_session_expired?
        !(klarna_session_expires_at.present? && klarna_session_expires_at >= DateTime.now)
      end

      def to_klarna(country = :us)
        SolidusKlarnaPayments::OrderSerializer.new(reload, country)
      end

      def authorized_klarna_payments
        payments.klarna_credit.find_all do |payment|
          payment.source.authorized?
        end
      end

      def captured_klarna_payments
        payments.klarna_credit.find_all do |payment|
          payment.source.captured?
        end
      end

      def available_klarna_payments?
        (authorized_klarna_payments.count + captured_klarna_payments.count) > 0
      end

      def can_be_cancelled_from_klarna?
        payments.klarna_credit.none? do |payment|
          !payment.source.cancelled?
        end
      end

      def update_klarna_shipments
        return unless shipment_state_changed? && shipment_state == "shipped"

        captured_klarna_payments.each do |payment|
          payment.payment_method.gateway.shipping_info(
            payment.source.order_id,
            payment.source.capture_id,
            shipping_info: to_klarna(
              payment.payment_method.preferred_country
            ).shipping_info
          )
        end
      end

      def update_klarna_customer
        # Check if the addresses were changed at all
        address_ids = %w{ship_address_id bill_address_id}
        return unless address_ids.any?{ |k| previous_changes.key?(k) }

        addresses = {}
        if previous_changes.key?("ship_address_id")
          addresses[:shipping_address] = AddressSerializer.new(ship_address)
        end

        if previous_changes.key?("bill_address_id")
          addresses[:billing_address] = AddressSerializer.new(bill_address)
        end

        authorized_klarna_payments.each do |payment|
          payment.payment_method.gateway.customer_details(
            payment.source.order_id,
            addresses
          )
        end
      end

      private

      def invalidate_klarna_session
        touch(:klarna_session_expires_at) if user_id_previously_changed? # rubocop:disable Rails/SkipsModelValidations
      end

      ::Spree::Order.prepend self
    end
  end
end
