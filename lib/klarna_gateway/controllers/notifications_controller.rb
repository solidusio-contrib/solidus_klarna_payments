module KlarnaGateway
  module NotificationsController
    def notification
      payment_source = Spree::KlarnaCreditPayment.find_by_order_id!(params[:order_id])

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
