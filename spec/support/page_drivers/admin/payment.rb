module PageDrivers
  module Admin
    class PaymentMenu < SitePrism::Section
      if KlarnaGateway.up_to_solidus?("1.3.99")
        element :logs, 'a[icon="archive"]'
      else
        element :logs, :xpath,'//*[@id="content-header"]/ul/li/a'
      end
    end

    class Payment < Base
      set_url '/admin/orders/{number}/payments/{payment_id}'

      section :payment_menu, PaymentMenu, '#content-header ul.header-actions'
    end
  end
end
