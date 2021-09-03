# frozen_string_literal: true

module SolidusKlarnaPayments
  class DiscountItemSerializer
    def initialize(order)
      @order = order
    end

    def to_hash
      {
        type: 'discount',
        quantity: 1,
        name: name,
        reference: reference,
        total_amount: (order.promo_total * 100).to_i,
        unit_price: (order.promo_total * 100).to_i,
        tax_rate: 0,
        total_tax_amount: 0
      }
    end

    private

    def name
      order.promotions.map(&:name).to_sentence
    end

    def reference
      order.all_adjustments.promotion.map do |promotion|
        promotion&.promotion_code&.value
      end.join(' ')
    end

    attr_reader :order
  end
end
