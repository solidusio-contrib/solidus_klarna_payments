# frozen_string_literal: true

module Spree
  class PaymentMethod
    class KlarnaCredit < Spree::PaymentMethod
      preference :api_key, :string
      preference :api_secret, :string
      preference :tokenization, :boolean
      preference :country, :string, default: 'us'
      preference :payment_method, :string

      preference :design, :string
      preference :color_details, :string
      preference :color_button, :string
      preference :color_button_text, :string
      preference :color_checkbox, :string
      preference :color_checkbox_checkmark, :string
      preference :color_header, :string
      preference :color_link, :string
      preference :color_border, :string
      preference :color_border_selected, :string
      preference :color_text, :string
      preference :color_text_secondary, :string
      preference :radius_border, :string

      validates :preferred_country, format: { with: /\A[a-z]{2}\z/ }
      validates :preferred_payment_method, inclusion: { in: %w(invoice pix base_account deferred_interest fixed_amount) }, allow_blank: true
      validates :preferred_color_details, :preferred_color_button, :preferred_color_button_text, :preferred_color_checkbox, :preferred_color_checkbox_checkmark,
        :preferred_color_header, :preferred_color_border_selected, :preferred_color_text, :preferred_color_text_secondary,
        format: { with: /\A#[0-9a-fA-F]{6}\z/ }, allow_blank: true
      validates :preferred_radius_border, numericality: { only_integer: true }, allow_blank: true

      validate :tokenization_flow

      # Remove the server setting from Gateway
      def defined_preferences
        super - [:server]
      end

      def gateway_class
        ActiveMerchant::Billing::KlarnaGateway
      end

      def partial_name
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

      def cancel(order_id)
        if source(order_id).fully_captured?
          gateway.refund(payment_amount(order_id), order_id)
        else
          gateway.cancel(order_id)
        end
      end

      def payment_profiles_supported?
        false
      end

      def source(order_id)
        payment_source_class.find_by(order_id: order_id)
      end

      def payment_amount(order_id)
        Spree::Payment.find_by(source: source(order_id)).display_total.cents
      end

      def capture(amount, order_id, params = {})
        order = spree_order(params)
        serialized_order = ::SolidusKlarnaPayments::OrderSerializer.new(order, options[:country]).to_hash
        klarna_params = { shipping_info: serialized_order[:shipping_info] }
        gateway.capture(amount, order_id, params.merge(klarna_params))
      end

      def try_void(payment)
        cancel(payment.order.klarna_order_id)
      end

      private

      def spree_order(options)
        Spree::Order.find_by(number: options[:order_id].split("-").first)
      end

      def tokenization_flow
        return unless preferred_tokenization && Spree::Config[:allow_guest_checkout]

        errors.add(:preferred_tokenization, I18n.t('spree.klarna.disable_guest_checkout'))
      end
    end
  end
end
