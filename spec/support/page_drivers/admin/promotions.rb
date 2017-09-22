module PageDrivers
  module Admin
    class Promotions < Base
      set_url '/admin/promotions'

      if KlarnaGateway.is_solidus?
        element :new_promotion_button, '#content-header .header-actions a'
      elsif KlarnaGateway.up_to_spree?('2.4.99')
        element :new_promotion_button, '#content-header .page-actions a'
      else
        element :new_promotion_button, '.content-header .page-actions a'
      end

      def new_promotion
        new_promotion_button.click
      end
    end
  end
end
