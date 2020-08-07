# frozen_string_literal: true

module SolidusKlarnaPayments
  module Spree
    module CheckoutControllerDecorator
      def completion_route
        klarna_completion_route || spree.order_path(@order)
      end

      def klarna_completion_route
        source = @order.payments.klarna_credit.map(&:source).last
        if source&.accepted? && source&.redirect_url?
          source.redirect_url
        end
      end

      ::Spree::CheckoutController.prepend self
    end
  end
end
