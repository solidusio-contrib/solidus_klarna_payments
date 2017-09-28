module PageDrivers
  module Admin
    class PaymentMenu < SitePrism::Section

      if KlarnaGateway.up_to_solidus?("1.3.99")
        element :logs, 'a[icon="archive"]'
      elsif KlarnaGateway.is_solidus?
        element :logs, :xpath,'//*[@id="content-header"]/ul/li/a'
      elsif KlarnaGateway.up_to_spree?('2.4.99')
        element :logs, 'a.fa-archive'
      elsif KlarnaGateway.is_spree?
        element :logs, 'a[icon="file"]'
      end
    end

    class Payment < Base
      set_url '/admin/orders/{number}/payments/{payment_id}'

      if KlarnaGateway.up_to_spree?('2.4.99')
        section :payment_menu, PaymentMenu, '#content-header ul.inline-menu'
      elsif KlarnaGateway.is_spree?
        section :payment_menu, PaymentMenu, '.content-header .page-actions'
      else
        section :payment_menu, PaymentMenu, '#content-header ul.header-actions'
      end
    end
  end
end
