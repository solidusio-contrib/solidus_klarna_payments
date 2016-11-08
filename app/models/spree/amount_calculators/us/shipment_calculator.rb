module Spree
  module AmountCalculators::US
    class ShipmentCalculator
      def adjust_with(shipment)
        yield().merge({
          tax_rate: 0,
          total_tax_amount: 0,
          unit_price: shipment.order.shipment_total.to_i * 100,
          total_amount: shipment.order.shipment_total.to_i * 100
        })
      end
    end
  end
end
