module KlarnaGateway
  module Admin
    module OrdersController
      def self.included(base)
        # TODO: only on klarna_session (maybe even not there)
        base.skip_action_callback(:ensure_valid_state)
      end

      def klarna
        load_order
        @klarna_order = @order.klarna_order
      end

      # WIP Update the Order with Klarna information
      def klarna_update
        # klarna_order = @order.klarna_order
        # redirect_to(spree.admin_order_klarna_path(@order))
      end

      def approve
        @order.klarna_approve!
        super
      end

      def klarna_extend
        load_order
        @order.klarna_extend!
        redirect_to(spree.admin_order_klarna_path(@order))
      end

      def klarna_release
        load_order
        @order.klarna_release!
        redirect_to(spree.admin_order_klarna_path(@order))
      end
    end
  end
end
