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
        name: name,
        reference: reference,
        total_amount: (@order.promo_total * 100).to_i,
        unit_price: (@order.promo_total * 100).to_i,
        tax_rate: 0,
        total_tax_amount: 0
      }
    end

    private

    def name
      @order.promotions.map(&:name).to_sentence
    end

    def reference
      @order.promotions.map(&:code).to_sentence
    end
  end
end
