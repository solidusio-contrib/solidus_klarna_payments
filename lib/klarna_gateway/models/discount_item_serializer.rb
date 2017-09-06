module KlarnaGateway
  class DiscountItemSerializer
    attr_reader :order

    def initialize(order)
      @order = order
    end

    def to_hash
      {
        type: "discount",
        quantity: 1,
        # send the name and the promo code
        name: name.presence || "Discount",
        reference: "Discount",
        total_amount: (@order.promo_total * 100).to_i,
        unit_price: (@order.promo_total * 100).to_i,
        tax_rate: 0,
        total_tax_amount: 0
      }
    end

    private

    def name
      @order.adjustments.map do |adjustment|
        if adjustment.promotion_code
          "#{adjustment.promotion_code.promotion.name} (#{adjustment.promotion_code.value})"
        end
      end.compact.to_sentence
    end
  end
end
