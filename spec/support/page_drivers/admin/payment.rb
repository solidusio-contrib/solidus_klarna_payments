module PageDrivers
  module Admin
    class PaymentMenu < SitePrism::Section
      if ENV["SOLIDUS_VERSION"] == "~> 1.4.0"
        element :logs, :xpath,'//*[@id="content-header"]/ul/li/a'
      else
        element :logs, 'a[icon="archive"]'
      end
    end

    class Payment < SitePrism::Page
      set_url '/admin/orders/{number}/payments/{payment_id}'

      section :payment_menu, PaymentMenu, '#content-header ul.header-actions'
    end
  end
end
