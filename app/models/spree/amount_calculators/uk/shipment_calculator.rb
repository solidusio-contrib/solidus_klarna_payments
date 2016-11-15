module Spree
  module AmountCalculators::UK
    class ShipmentCalculator
      def adjust_with(shipment)
        yield().merge({
          total_tax_amount: tax_amount(shipment),
          tax_rate: tax_rate(shipment)
        })
      end

      private

      def tax_amount(shipment)
        shipment.included_tax_total.to_i * 100
      end

      def tax_rate(shipment)
        if shipment.included_tax_total == 0
          0
        else
          (shipment.total_amount / shipment.included_tax_total) * 100
        end
      end
    end
  end
end
