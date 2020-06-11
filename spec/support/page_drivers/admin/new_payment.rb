# frozen_string_literal: true

module PageDrivers
  module Admin
    class NewPayment < Base
      set_url '/admin/orders/{number}/payments/new'

      elements :payment_methods, '[data-hook="admin_payment_form_fields"] [data-hook="payment_method_field"]'
      element :update_button, '[data-hook="buttons"] button'

      def select_check
        payment_methods.find{ |e| e.text.downcase.match(/check/) }.click
      end
    end
  end
end
