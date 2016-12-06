module KlarnaGateway
  module Admin
    module OrdersController
      def self.included(base)
        # TODO: only on klarna_session (maybe even not there)
        base.skip_action_callback(:ensure_valid_state)
        base.before_action(:check_klarna_payment_cancel, only: [:cancel])
      end

      def approve
        @order.klarna_approve!
        super
      end

      private

      def check_klarna_payment_cancel
        if @order.has_klarna_payments?
          flash[:error] = "Please cancel all Klarna payments before canceling this order."
          redirect_to(spree.admin_order_payments_path(@order))
        end
      end
    end
  end
end
