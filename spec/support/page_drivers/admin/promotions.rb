module PageDrivers
  module Admin
    class Promotions < Base
      set_url '/admin/promotions'

      if KlarnaGateway.up_to_spree?('2.3.99')
        element :new_promotion_button, '#content-header ul.inline-menu a'
      else
        element :new_promotion_button, '#content-header .header-actions a'
      end

      def new_promotion

        new_promotion_button.click
      end
    end
  end
end
