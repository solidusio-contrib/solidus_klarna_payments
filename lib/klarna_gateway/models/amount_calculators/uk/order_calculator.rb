module KlarnaGateway
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
          result[:order_lines] << KlarnaGateway::DiscountItemSerializer.new(order).to_hash
        end
        if skip_personal_data
          result.delete_if { |k,v| SENSITIVE_ATTRIBUTES.include?(k) }
        end
        result
      end

      def line_item_strategy
        KlarnaGateway::AmountCalculators::UK::LineItemCalculator.new
      end

      def shipment_strategy
        KlarnaGateway::AmountCalculators::UK::ShipmentCalculator.new
      end

      def locale(region)
        case region
        when :de then "de-DE"
        else "en-GB"
        end
      end
    end
  end
end

