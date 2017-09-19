module PageDrivers
  module Admin
    class Orders < Base
      set_url '/admin/orders'

      elements :orders, 'table#listing_orders [data-hook="admin_orders_index_rows"]'

      def select_first_order
        scroll_to(orders.first.find('a.fa-edit')).click
      end
    end
  end
end

