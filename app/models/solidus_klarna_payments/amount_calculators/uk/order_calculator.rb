# frozen_string_literal: true

module SolidusKlarnaPayments
  module AmountCalculators
    module Uk
      # The UK store expects tax amounts directly on the line items.
      class OrderCalculator
        SENSITIVE_ATTRIBUTES = [:billing_address, :shipping_address].freeze
        attr_reader :skip_personal_data

        def initialize(skip_personal_data)
          @skip_personal_data = skip_personal_data
        end

        def adjust_with(order)
          result = yield
          result[:order_amount] = order.display_total.cents
          if order.promo_total < 0
            result[:order_lines] << SolidusKlarnaPayments::DiscountItemSerializer.new(order).to_hash
          end
          if skip_personal_data
            result.delete_if { |k, _v| SENSITIVE_ATTRIBUTES.include?(k) }
          end
          result
        end

        def line_item_strategy
          SolidusKlarnaPayments::AmountCalculators::Uk::LineItemCalculator.new
        end

        def shipment_strategy
          SolidusKlarnaPayments::AmountCalculators::Uk::ShipmentCalculator.new
        end

        def locale(region)
          case region
          when :de then "de-DE"
          when :se then "sv-SE"
          when :at then "de-AT"
          when :se then "sv-SE"
          when :nl then "nl-NL"
          when :dk then "da-DK"
          when :no then "nb-NO"
          when :fi then "fi-FI"
          else "en-GB"
          end
        end
      end
    end
  end
end
