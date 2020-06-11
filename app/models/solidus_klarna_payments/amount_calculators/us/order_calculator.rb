# frozen_string_literal: true

module SolidusKlarnaPayments
  module AmountCalculators
    module Us
      # The US line items will not include tax so the tax amount is added as
      # an additional sales_tax order_line. The order also has total_tax_amount set.
      class OrderCalculator
        def adjust_with(order)
          result = yield
          result[:order_amount] = order.display_total.cents
          result[:order_tax_amount] = order.display_tax_total.cents

          if order.tax_total > 0
            result[:order_lines] << tax_line(order)
          end

          if order.promo_total < 0
            result[:order_lines] << SolidusKlarnaPayments::DiscountItemSerializer.new(order).to_hash
          end

          result
        end

        def line_item_strategy
          SolidusKlarnaPayments::AmountCalculators::Us::LineItemCalculator.new
        end

        def shipment_strategy
          SolidusKlarnaPayments::AmountCalculators::Us::ShipmentCalculator.new
        end

        def locale(_region)
          "en-US"
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
      end
    end
  end
end
