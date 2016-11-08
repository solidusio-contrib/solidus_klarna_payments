module Spree
  class OrderSerializer
    attr_reader :order

    def initialize(order, region = :us)
      @order = order
      @region = region
    end

    def to_hash
      strategy.adjust_with(order) do
        config
      end
    end

    private

    def config
      {
        purchase_country: order.billing_address.country.iso,
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
        LineItemSerializer.new(line_item, strategy.line_item_strategy).to_hash
      end
    end

    def shipments
      order.shipments.map do |shipment|
        ShipmentSerializer.new(shipment, strategy.shipment_strategy).to_hash
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

    def strategy
      @strategy ||= case @region.downcase.to_sym
        when :us then Spree::AmountCalculators::US::OrderCalculator.new
        else Spree::AmountCalculators::UK::OrderCalculator.new
        end
    end
  end
end
