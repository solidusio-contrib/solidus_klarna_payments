module PageDrivers
  module Admin
    class Customer < Base
      if KlarnaGateway.is_solidus?
        set_url '/admin/orders/{number}/customer/edit'
      else
        set_url '/admin/orders/{number}/customer'
      end

      if KlarnaGateway.is_solidus?
        section :menu, PageDrivers::Admin::OrderMenu, '.container nav ul.tabs'
      else
        section :menu, PageDrivers::Admin::OrderMenu, 'aside#sidebar ul'
      end

      section :payment_menu, PaymentMenu, '#content-header ul.header-actions'
    end
  end
end

