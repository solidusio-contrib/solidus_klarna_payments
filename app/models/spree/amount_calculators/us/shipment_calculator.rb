module Spree
  module AmountCalculators::US
    class ShipmentCalculator
      def adjust_with(shipment)
        yield().merge({
          total_tax_amount: 0
        })
      end
    end
  end
end
