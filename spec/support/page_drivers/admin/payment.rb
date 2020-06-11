# frozen_string_literal: true

module PageDrivers
  module Admin
    class PaymentMenu < SitePrism::Section
      element :logs, :xpath, '//*[@id="content-header"]/ul/li/a'
    end

    class Payment < Base
      set_url '/admin/orders/{number}/payments/{payment_id}'

      section :payment_menu, PaymentMenu, '#content-header ul.header-actions'
    end
  end
end
