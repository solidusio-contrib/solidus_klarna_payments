module Spree
  module AmountCalculators::US
    # The US line items will not include tax so the tax amount is added as
    # an additional sales_tax order_line. The order also has total_tax_amount set.
    class OrderCalculator

      def adjust_with(order)
        result= yield
        result.merge({
          order_amount: order.display_total.cents,
          order_tax_amount: order.display_tax_total.cents,
        })
        order_lines: result[:order_lines] << tax_line(order)
      end

      def line_item_strategy
        Spree::AmountCalculators::US::LineItemCalculator.new
      end

      def shipment_strategy
        Spree::AmountCalculators::US::ShipmentCalculator.new
      end

      private

      def tax_line(order)
        {
          type: "sales_tax",
          quantity: 1,
          name: "Sales Tax",
          reference: "Sales Tax",
          unit_price: order.display_tax_total.cents,
          total_amount: order.display_tax_total.cents,
          tax_rate: 0,
          total_tax_amount: 0
        }
      end

      def discount_line(order)

      end
    end
  end
end

