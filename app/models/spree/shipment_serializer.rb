module Spree
  class ShipmentSerializer
    attr_reader :shipment, :strategy

    def initialize(shipment, strategy)
      @shipment = shipment
      @strategy = strategy
    end

    def to_hash
      strategy.adjust_with(shipment) do
        {
          type: 'shipping_fee',
          reference: shipment.number,
          name: shipment.number,
          quantity: 1,
          unit_price: unit_price ,
          total_amount: total_amount,
          total_tax_amount: total_tax_amount,
          tax_rate: tax_rate
        }
      end
    end

    private

    def unit_price
      shipment.pre_tax_amount.to_i * 100
    end

    def total_amount
      shipment.final_price.to_i * 100
    end

    def total_tax_amount
      shipment.tax_total.to_i * 100
    end

    def tax_rate
      return total_amount if total_amount == 0
      ((unit_price / total_amount) * 100).to_i
    end
  end
end
