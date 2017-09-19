module PageDrivers
  module Admin
    class Customer < Base
      set_url '/admin/orders/{number}/customer/edit'
      section :menu, PageDrivers::Admin::OrderMenu, '.container nav ul.tabs'

      section :payment_menu, PaymentMenu, '#content-header ul.header-actions'
    end
  end
end

