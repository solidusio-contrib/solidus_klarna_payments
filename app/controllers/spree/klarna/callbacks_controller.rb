# frozen_string_literal: true

module Spree
  module Klarna
    class CallbacksController < Spree::StoreController
      skip_before_action :verify_authenticity_token

      def notification
        payment_source = Spree::KlarnaCreditPayment.find_by!(order_id: params[:order_id])

        case params[:event_type]
        when "FRAUD_RISK_ACCEPTED"
          payment_source.accept!
        when "FRAUD_RISK_REJECTED", "FRAUD_RISK_STOPPED"
          payment_source.reject!
        end

        payment_source.payments.first.notify!(params)

        payment_source.order.touch
        render plain: "ok"
      end

      def push
        render plain: "ok"
      end
    end
  end
end
