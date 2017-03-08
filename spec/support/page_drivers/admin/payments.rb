module PageDrivers
  module Admin
    class PaymentItem < SitePrism::Section
      element :identifier, :xpath, 'td[1]'
      element :date, :xpath, 'td[2]'
      element :amount, :xpath, 'td[3]'
      element :payment_method, :xpath, 'td[4]'
      element :transaction_id, :xpath, 'td[5]'
      element :payment_state, :xpath, 'td[6]'
      element :actions, :xpath, 'td[7]'

      def is_check?
        !payment_method.text.match(/Check/).nil?
      end

      def is_klarna?
        !payment_method.text.match(/Fraud Status/).nil?
      end

      def is_klarna_authorized?
        !payment_method.text.match(/AUTHORIZED/).nil?
      end

      def is_klarna_pending?
        !payment_method.text.match(/PENDING/).nil?
      end

      def is_klarna_captured?
        !payment_method.text.match(/CAPTURED/).nil?
      end

      def is_klarna_cancelled?
        !payment_method.text.match(/CANCELLED/).nil?
      end

      def is_pending?
        !payment_state.text.match(/PENDING/).nil?
      end

      def is_completed?
        !payment_state.text.match(/COMPLETED/).nil?
      end

      def is_void?
        !payment_state.text.match(/VOID/).nil?
      end

      def capture!
        actions.find('[data-action="capture"]').click
      end

      def cancel!
        actions.find('[data-action="cancel"]').click
      end
    end

    class Payments < SitePrism::Page
      set_url '/admin/orders/{number}/payments'

      sections :payments, PaymentItem, '[data-hook="payment_list"] tbody tr[data-hook="payments_row"]'
      section :menu, PageDrivers::Admin::OrderMenu, '.container nav ul.tabs'
      element :new_payment_button, '#content-header .header-actions #new_payment_section a'
    end
  end
end

