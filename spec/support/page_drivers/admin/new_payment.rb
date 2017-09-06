module PageDrivers
  module Admin
    class NewPayment < SitePrism::Page
      set_url '/admin/orders/{number}/payments/new'

      elements :payment_methods, '[data-hook="admin_payment_form_fields"] .field [data-hook="payment_method_field"]'
      element :update_button, '[data-hook="buttons"] button'

      def select_check
        payment_methods.find{|e| e.text.match(/Check/)}.click
      end
    end
  end
end

