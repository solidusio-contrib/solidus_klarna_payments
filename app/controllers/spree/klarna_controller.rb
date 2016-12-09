module Spree
  class KlarnaController < Spree::StoreController

    skip_before_action :verify_authenticity_token

    def notification
      if params[:event_type] === "FRAUD_RISK_ACCEPTED"
        klarna_order = Spree::KlarnaCreditPayment.where(klarna_order_id: params[:order_id]).first
        klarna_order.accept!
      elsif params[:event_type] === "FRAUD_RISK_REJECTED"
        klarna_order = Spree::KlarnaCreditPayment.where(klarna_order_id: params[:order_id]).first
        klarna_order.reject!
      end

      klarna_order.order.touch
      render text: "ok"
    end

    def push
      render text: "ok"
    end
  end
end
