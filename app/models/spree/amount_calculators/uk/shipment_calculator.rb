module Spree
  module AmountCalculators::US
    class ShipmentCalculator
      def adjust_with(shipment)
        yield().merge({
          tax_rate: tax_rate(shipment),
          total_tax_amount: total_tax_amount(shipment),
          unit_price: (shipment.order.shipment_total. * 100).to_i,
          total_amount: shipment.order.shipment_total.to_i * 100
        })
      end

      private

      def tax_rate(shipment)
        if shipment.adjustments.tax.count == 1
          (shipment.adjustments.tax.first.source.amount * 100).to_i
        else
          0
        end
      end
    end
  end
end
