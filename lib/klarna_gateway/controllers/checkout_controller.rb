module KlarnaGateway
  module CheckoutController
    def completion_route
      klarna_completion_route || spree.order_path(@order)
    end

    def klarna_completion_route
      source = @order.payments.klarna_credit.map(&:source).last
      if source && source.accepted? && source.redirect_url?
        source.redirect_url
      end
    end
  end
end
