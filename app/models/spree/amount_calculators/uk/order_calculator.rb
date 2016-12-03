module Spree
  module AmountCalculators::UK
    # The UK store expects tax amounts directly on the line items.
    class OrderCalculator
      SENSITIVE_ATTRIBUTES = [:billing_address, :shipping_address]
      attr_reader :skip_personal_data

      def initialize(skip_personal_data)
        @skip_personal_data = skip_personal_data
      end

      def adjust_with(order)
        result = yield
        result.merge!({
          order_amount: order.display_total.cents
        })
        if order.promo_total < 0
          result[:order_lines] << discount_line(order)
        end
        if skip_personal_data
          result.delete_if { |k,v| SENSITIVE_ATTRIBUTES.include?(k) }
        end
        result
      end

      def line_item_strategy
        Spree::AmountCalculators::UK::LineItemCalculator.new
      end

      def shipment_strategy
        Spree::AmountCalculators::UK::ShipmentCalculator.new
      end

      def locale(region)
        case region
        when :de then "de-DE"
        else "en-GB"
        end
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

