module PageDrivers
  module Admin
    class Orders < SitePrism::Page
      set_url '/admin/orders'

      elements :orders, 'table#listing_orders [data-hook="admin_orders_index_rows"]'

      def select_first_order
        orders.first.find('a.fa-edit').click
      end
    end
  end
end

