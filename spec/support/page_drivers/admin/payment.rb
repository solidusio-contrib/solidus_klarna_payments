module PageDrivers
  module Admin
    class PaymentMenu < SitePrism::Section
      element :logs, 'a[icon="archive"]'
    end

    class Payment < SitePrism::Page
      set_url '/admin/orders/{number}/payments/{payment_id}'

      section :payment_menu, PaymentMenu, '#content-header ul.header-actions'
    end
  end
end

