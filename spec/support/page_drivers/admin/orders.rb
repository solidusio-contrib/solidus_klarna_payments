module PageDrivers
  module Admin
    class Orders < Base
      def visit
        @page.visit('/admin/orders')
      end

      def select_first_order
        within 'table#listing_orders tbody' do
          all('tr').first.find('a.fa-edit').click
        end
      end


      def visit_payments
        within 'li[data-hook="admin_order_tabs_payments"]' do
          find('a').click
        end
      end
    end
  end
end

