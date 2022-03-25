# frozen_string_literal: true

module SolidusKlarnaPayments
  module Api
    class CallbacksController < ::Spree::Api::BaseController
      include ::Spree::Core::ControllerHelpers::Order

      def notification
        payment_source = ::Spree::KlarnaCreditPayment.find_by!(
          spree_order_id: @order.id,
          order_id: params[:klarna_order_id]
        )

        case params[:event_type]
        when 'FRAUD_RISK_ACCEPTED'
          payment_source.accept!
        when 'FRAUD_RISK_REJECTED', 'FRAUD_RISK_STOPPED'
          payment_source.reject!
        end

        payment_source.payments.first.notify!(params)

        # rubocop:disable Rails/SkipsModelValidations
        payment_source.order.touch
        # rubocop:enable Rails/SkipsModelValidations
        render plain: 'ok'
      end

      def push
        render plain: 'ok'
      end
    end
  end
end
