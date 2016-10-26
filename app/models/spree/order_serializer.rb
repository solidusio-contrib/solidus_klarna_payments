module Spree
  class OrderSerializer
    def initialize(order)
      @order = order
    end

    def to_hash
      config
    end

    private
      def config
        {
         purchase_country: "US" ,
         purchase_currency: @order.currency ,
         order_amount: o.amount.to_f,
         order_tax_amount: o.tax_total.to_f
        }
      end

      def list_items

      end


      def billing_adress

      end


      # ...
  end
end
