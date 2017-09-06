module KlarnaGateway
  module AmountCalculators::US
    class ShipmentCalculator
      def adjust_with(shipment)
        yield().merge({
          unit_price: unit_price(shipment),
          total_amount: total_amount(shipment),
          total_tax_amount: total_tax_amount(shipment),
          tax_rate: tax_rate(shipment)
        })
      end

      private

      # In US taxes are calculated on the whole sale.
      # Taxes related to the shipment will be added to the sale tax
      def unit_price(shipment)
        (shipment.pre_tax_amount * 100).to_i
      end

      def total_amount(shipment)
        unit_price(shipment)
      end

      def total_tax_amount(shipment)
        0
      end

      def tax_rate(shipment)
        0
      end
    end
  end
end
