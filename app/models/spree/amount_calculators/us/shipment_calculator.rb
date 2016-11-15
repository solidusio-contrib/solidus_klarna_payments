module Spree
  module AmountCalculators::US
    class ShipmentCalculator
      def adjust_with(shipment)
        yield()
      end
    end
  end
end
