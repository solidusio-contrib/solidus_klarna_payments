module KlarnaGateway
  module AmountCalculators::US
    class LineItemCalculator
      def adjust_with(line_item)
        yield().merge({
          total_tax_amount: 0,
          tax_rate: 0,
          unit_price: unit_price(line_item),
          total_amount: total_amount(line_item)
        })
      end

      private

      def unit_price(line_item)
        line_item.display_price.cents
      end

      def total_amount(line_item)
        unit_price(line_item) * line_item.quantity
      end
    end
  end
end
