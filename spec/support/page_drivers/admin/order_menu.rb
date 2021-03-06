# frozen_string_literal: true

module PageDrivers
  module Admin
    class OrderMenu < SitePrism::Section
      element :payments, 'li[data-hook="admin_order_tabs_payments"] a'
      element :customer, 'li[data-hook="admin_order_tabs_customer_details"] a'

      def shipments
        root_element.all('li[data-hook="admin_order_tabs_order_details"]').find{ |e| e.text.downcase.match(/shipments/) }.find('a')
      end
    end
  end
end
