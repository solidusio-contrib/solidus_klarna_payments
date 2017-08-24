module PageDrivers
  module Admin
    class Promotions < SitePrism::Page
      set_url '/admin/promotions'

      element :new_promotion_button, '#content-header .header-actions a'

      def new_promotion
        new_promotion_button.click
      end
    end
  end
end
