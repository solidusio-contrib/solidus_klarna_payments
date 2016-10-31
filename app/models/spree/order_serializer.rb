module Spree
  class OrderSerializer
    attr_reader :order

    def initialize(order)
      @order = order
    end

    def to_hash
      config
    end

    private

    def config
      {
        purchase_country: "US" ,
        purchase_currency: order.currency,
        locale: "en-us",
        # amount with taxes and adjustments
        order_amount: order.display_total.cents,
        billing_address: billing_address,
        shipping_address: shipping_address,
        order_lines: order_lines,
        merchant_reference1: order.number,
      }
    end

    def order_lines
      line_items + shipments
    end

    def line_items
      order.line_items.map do |line_item|
        LineItemSerializer.new(line_item).to_hash
      end
    end

    def shipments
      order.shipments.map do |shipment|
        ShipmentSerializer.new(shipment).to_hash
      end
    end

    def billing_address
      {
        email: @order.email
      }.merge(
        AddressSerializer.new(order.billing_address).to_hash
      )
    end

    def shipping_address
      {
        email: @order.email
      }.merge(
        AddressSerializer.new(order.shipping_address).to_hash
      )
    end
  end
end
