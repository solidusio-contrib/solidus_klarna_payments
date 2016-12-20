module Spree
  class Gateway
    class KlarnaCredit < Gateway
      preference :api_key, :string
      preference :api_secret, :string
      preference :country, :string
      preference :environment, :string

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

      def cancel(order_id)
        if source(order_id).fully_captured?
          provider.refund(payment_amount(order_id), order_id)
        else
          provider.cancel(order_id)
        end
      end

      def payment_profiles_supported?
        false
      end

      def source(order_id)
        payment_source_class.find_by_order_id(order_id)
      end

      def payment_amount(order_id)
        Spree::Payment.find_by(source: source(order_id)).display_amount.cents
      end
    end
  end
end
