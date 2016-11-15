module Spree
  module AmountCalculators::UK
    # The UK store expects tax amounts directly on the line items.
    class OrderCalculator

      def adjust_with(order)
        result = yield
        result.merge!({
          order_amount: order.display_total.cents
        })
        if order.promo_total < 0
          result[:order_lines] << discount_line(order)
        end
        result
      end

      def line_item_strategy
        Spree::AmountCalculators::UK::LineItemCalculator.new
      end

      def shipment_strategy
        Spree::AmountCalculators::UK::ShipmentCalculator.new
      end

      private

      def discount_line(order)
        {
          type: "discount",
          quantity: 1,
          name: "Discount",
          reference: "Discount",
          total_amount: (order.promo_total * 100).to_i,
          unit_price: (order.promo_total * 100).to_i,
          tax_rate: 0,
          total_tax_amount: 0
        }
      end
    end
  end
end

