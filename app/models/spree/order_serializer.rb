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
        order_lines: order_lines,
        merchant_reference1: order.number,
      }.tap do |cfg|
        cfg[:shipping_address] = shipping_address if order.ship_address_id?
      end
    end

    def order_lines
      line_items + shipments
    end

    def line_items
      order.line_items.map do |line_item|
        LineItemSerializer.new(line_item)
      end
    end

    def shipments
      order.shipments.map do |shipment|
        ShipmentSerializer.new(shipment)
      end
    end

    def billing_address
      format_address(order.billing_address)
    end

    def shipping_address
      format_address(order.shipping_address)
    end

    def format_address(addr)
      {
        organization_name: addr.company,
        given_name: addr.first_name,
        family_name: addr.last_name,
        street_address: addr.address1,
        street_address2: addr.address2,
        postal_code: addr.zipcode,
        city: addr.city,
        region: addr.state_name,
        phone: addr.phone,
        country: addr.country.iso,
        email: order.email
      }
    end
  end
end
