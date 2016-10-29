module Spree
  class ShipmentSerializer
    attr_reader :shipment

    def initialize(shipment)
      @shipment = shipment
    end

    def to_hash
      {
        type: 'shipping_fee',
        reference: shipment.number,
        name: shipment.number,
        quantity: 1,
        total_amount: shipment.display_final_price.cents,
        unit_price: shipment.display_final_price.cents,
        tax_rate: tax_rate,
        total_tax_amount: total_tax_amount
      }
    end

    private

    def total_tax_amount
      (shipment.additional_tax_total * 100).to_i
    end

    def tax_rate
      ((shipment.additional_tax_total / shipment.cost) * 10000).to_i
    end
  end
end
