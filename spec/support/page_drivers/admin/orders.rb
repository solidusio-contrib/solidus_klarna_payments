# frozen_string_literal: true

module PageDrivers
  module Admin
    class Orders < Base
      set_url '/admin/orders'

      elements :orders, 'table#listing_orders [data-hook="admin_orders_index_rows"]'

      def select_first_order
        orders.first.find('[data-action="edit"]').click
      end
    end
  end
end
