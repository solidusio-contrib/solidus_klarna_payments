module KlarnaGateway
  module AmountCalculators::UK
    class ShipmentCalculator
      def adjust_with(shipment)
        yield().merge({
          total_tax_amount: tax_amount(shipment),
          tax_rate: tax_rate(shipment),
          unit_price: unit_price(shipment)
        })
      end

      private

      def tax_amount(shipment)
        (shipment.included_tax_total * 100).to_i
      end

      def tax_rate(shipment)
        if shipment.included_tax_total == 0
          0
        elsif shipment.adjustments.tax.count == 1
          (shipment.adjustments.tax.first.source.amount * 10_000).to_i
        else
          (((shipment.amount / shipment.pre_tax_amount) - 1) * 10_000).to_i
        end
      end

      def unit_price(shipment)
        (shipment.amount * 100).to_i
      end
    end
  end
end
