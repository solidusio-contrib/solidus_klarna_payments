module PageDrivers
  module Admin
    class OrderMenu < SitePrism::Section
      element :payments, 'li[data-hook="admin_order_tabs_payments"]'
      element :shipments, :xpath, '(//li[@data-hook="admin_order_tabs_order_details"])[2]'
      element :customer, 'li[data-hook="admin_order_tabs_customer_details"]'
    end
  end
end
