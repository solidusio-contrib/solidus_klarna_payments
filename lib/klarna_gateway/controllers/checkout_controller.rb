module KlarnaGateway
  module CheckoutController
    def completion_route
      klarna_completion_route || spree.order_path(@order)
    end

    def klarna_completion_route
      source = @order.has_klarna_payments? && @order.payments.last.source
      if source && source.accepted? && source.redirect_url?
        source.redirect_url
      end
    end
  end
end
