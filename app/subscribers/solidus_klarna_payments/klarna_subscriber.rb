# frozen_string_literal: true

module SolidusKlarnaPayments
  module KlarnaSubscriber
    include Omnes::Subscriber

    handle :order_recalculated, with: :update_klarna_shipments
    handle :order_recalculated, with: :update_klarna_customer

    def update_klarna_shipments(event)
      order = event.payload[:order]
      order.update_klarna_shipments
    end

    def update_klarna_customer(event)
      order = event.payload[:order]
      order.update_klarna_customer
    end
  end
end
