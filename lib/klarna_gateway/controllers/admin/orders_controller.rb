module KlarnaGateway
  module Admin
    module OrdersController
      def self.included(base)
        base.before_action(:check_klarna_payment_cancel, only: [:cancel])
      end

      private

      def check_klarna_payment_cancel
        if @order.has_klarna_payments? && @order.can_be_cancelled_from_klarna?
          flash[:error] = "Please cancel all Klarna payments before canceling this order."
          redirect_to(spree.admin_order_payments_path(@order))
        end
      end
    end
  end
end
