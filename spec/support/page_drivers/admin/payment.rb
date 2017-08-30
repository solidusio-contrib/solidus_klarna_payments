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

      if KlarnaGateway.up_to_spree?('2.3.99')
        section :payment_menu, PaymentMenu, '#content-header ul.inline-menu'
      else
        section :payment_menu, PaymentMenu, '#content-header ul.header-actions'
      end
    end
  end
end
