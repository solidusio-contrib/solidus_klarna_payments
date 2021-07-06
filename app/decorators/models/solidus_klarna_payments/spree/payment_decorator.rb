# frozen_string_literal: true

module SolidusKlarnaPayments
  module Spree
    module PaymentDecorator
      def self.prepended(base)
        base.class_eval do
          scope :klarna_credit, ->{ where(source_type: 'Spree::KlarnaCreditPayment') }
          scope :risky, -> do
            joins("JOIN spree_klarna_credit_payments ON spree_payments.source_id = spree_klarna_credit_payments.id")
              .where("avs_response IN (?) OR (cvv_response_code IS NOT NULL and cvv_response_code != 'M') OR state = 'failed' OR (fraud_status = 'REJECTED' AND source_type = 'Spree::KlarnaCreditPayment')", ::Spree::Payment::RISKY_AVS_CODES)
          end

          scope :klarna_risky, -> do
            joins("JOIN spree_klarna_credit_payments ON spree_payments.source_id = spree_klarna_credit_payments.id")
              .where("fraud_status = 'REJECTED' AND source_type = 'Spree::KlarnaCreditPayment'")
          end

          delegate :can_refresh?, :can_extend_period?, :can_capture?, :can_cancel?, :can_release?, to: :source
        end
      end

      def refresh!
        payment_gateway.get_and_update_source(klarna_order_id)
      end

      def extend_period!
        payment_gateway.extend_period(klarna_order_id).tap do |response|
          record_response(response)
        end
      end

      def release!
        payment_gateway.release(klarna_order_id).tap do |response|
          record_response(response)
        end
      end

      def refund!
        payment_gateway.refund(display_total.cents, klarna_order_id).tap do |response|
          handle_void_response(response)
        end
      end

      def notify!(params)
        response = ActiveMerchant::Billing::Response.new(
          true,
          "Updated (via notification) order Klarna id: #{params[:order_id]}",
          params,
          {}
        )
        record_response(response)
      end

      def klarna_order
        payment_gateway.get(klarna_order_id).body
      end

      def is_klarna?
        source.present? && source.is_a?(::Spree::KlarnaCreditPayment)
      end

      def is_valid_klarna?
        is_klarna? && source.order_id.present?
      end

      private

      def klarna_order_id
        source.order_id
      end

      def payment_gateway
        payment_method.gateway
      end

      ::Spree::Payment.prepend self
    end
  end
end
