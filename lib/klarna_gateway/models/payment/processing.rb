module KlarnaGateway
  module Payment
    module Processing
      def self.included(base)
        delegate :can_refresh?, :can_extend_period?, :can_capture?, :can_cancel?, :can_release?, to: :source
      end

      def refresh!
        payment_provider.get_and_update_source(klarna_order_id)
      end

      def extend_period!
        payment_provider.extend_period(klarna_order_id).tap do |response|
          record_response(response)
        end
      end

      def release!
        payment_provider.release(klarna_order_id).tap do |response|
          record_response(response)
        end
      end

      def refund!
        payment_provider.refund(self.display_amount.cents, klarna_order_id).tap do |response|
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
        payment_provider.get(klarna_order_id).body
      end

      def is_klarna?
        source.present? && source.is_a?(Spree::KlarnaCreditPayment)
      end

      def is_valid_klarna?
        is_klarna? && source.order_id.present?
      end

      private

      def klarna_order_id
        source.order_id
      end

      def payment_provider
        payment_method.provider
      end
    end
  end
end
