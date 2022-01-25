# frozen_string_literal: true

module SolidusKlarnaPayments
  module KlarnaSubscriber
    include ::Spree::Event::Subscriber

    event_action :update_klarna_shipments, event_name: :order_recalculated
    event_action :update_klarna_customer, event_name: :order_recalculated

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
