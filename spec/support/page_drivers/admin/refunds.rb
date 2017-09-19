module PageDrivers
  module Admin
    class OrderPaymentsRefunds < SitePrism::Page
      set_url '/admin/orders/{number}/payments/{payment_id}/refunds/new'

      element :reason_field, '#refund_refund_reason_id'
      element :continue_button, :xpath, '//*[@id="new_refund"]/fieldset/div[2]/button'

      def select_reason!
        reason_field.all('option').last.select_option
      end

      def continue
        continue_button.click
      end
    end
  end
end
