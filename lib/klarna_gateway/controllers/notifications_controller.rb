module KlarnaGateway
  module NotificationsController
    def notification
      payment_source = Spree::KlarnaCreditPayment.find_by_order_id(params[:klarna][:order_id])

      case params[:klarna][:event_type]
        when "FRAUD_RISK_ACCEPTED"
          payment_source.accept!
        when "FRAUD_RISK_REJECTED", "FRAUD_RISK_STOPPED"
          payment_source.reject!
      end

      payment_source.payments.first.notify!(params)

      payment_source.order.touch
      render text: "ok"
    end

    def push
      render text: "ok"
    end
  end
end
