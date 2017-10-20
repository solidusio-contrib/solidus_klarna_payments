module KlarnaGateway
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
          name: shipment.shipping_method.name,
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
      (pre_tax_amount * 100).to_i
    end

    def total_amount
      (shipment.final_price * 100).to_i
    end

    def total_tax_amount
      (shipment.tax_total * 100).to_i
    end

    def tax_rate
      return 0 if total_tax_amount == 0 || total_amount == 0
      (((shipment.final_price / pre_tax_amount) - 1) * 10000).to_i
    end

    # Backport for Spree 3.0 and 3.1
    # https://github.com/spree/spree/pull/7357
    def pre_tax_amount
      if shipment.pre_tax_amount == 0
        shipment.discounted_amount - shipment.included_tax_total
      else
        shipment.pre_tax_amount
      end
    end
  end
end
