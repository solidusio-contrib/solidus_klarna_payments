module PageDrivers
  module Admin
    class Refunds < SitePrism::Page
      set_url '/admin/orders/{number}/payments/{number}/refunds/new'

      element :reason_field, '#s2id_refund_refund_reason_id'
      element :continue_button, :xpath, '//*[@id="new_refund"]/fieldset/div[2]/button'

      def select_reason!
        reason_field.click
        first('#select2-result-label-2').select_option
      end

      def continue
        continue_button.click
      end
    end
  end
end
