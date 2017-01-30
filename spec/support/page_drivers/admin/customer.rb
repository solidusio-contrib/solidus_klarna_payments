module PageDrivers
  module Admin
    class Customer < SitePrism::Page
      set_url '/admin/orders/{number}/customer/edit'

      section :payment_menu, PaymentMenu, '#content-header ul.header-actions'
    end
  end
end

