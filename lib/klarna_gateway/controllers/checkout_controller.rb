module KlarnaGateway
  module CheckoutController
    def completion_route
      source = @order.has_klarna_payments? && @order.payments.last.source
      if source && source.accepted? && source.redirect_url?
        source.redirect_url
      else
        spree.order_path(@order)
      end
    end
  end
end
