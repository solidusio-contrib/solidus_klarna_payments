module Spree
  module AmountCalculators::US
    class LineItemCalculator
      def adjust_with(line_item)
        yield().merge({
          total_tax_amount: 0,
          tax_rate: 0,
          unit_price: unit_price(line_item)
        })
      end

      private

      def unit_price(line_item)
        line_item.display_pre_tax_amount.cents
      end
    end
  end
end
