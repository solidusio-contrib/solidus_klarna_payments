module Spree
  module AmountCalculators::UK
    class ShipmentCalculator
      def adjust_with(shipment)
        yield()
      end
    end
  end
end
