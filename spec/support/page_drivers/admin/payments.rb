module PageDrivers
  module Admin
    class PaymentItem < SitePrism::Section
      element :identifier, :xpath, 'td[1]'
      element :date, :xpath, 'td[2]'
      element :amount, :xpath, 'td[3]'
      element :payment_method, :xpath, 'td[4]'

      if KlarnaGateway.up_to_spree?('2.3.99')
        element :payment_state, :xpath, 'td[5]'
        element :actions, :xpath, 'td[6]'
      else
        element :payment_state, :xpath, 'td[6]'
        element :actions, :xpath, 'td[7]'
      end

      def is_check?
        !payment_method.text.match(/Check/i).nil?
      end

      def is_klarna?
        !payment_method.text.match(/Fraud Status/i).nil?
      end

      def is_klarna_authorized?
        !payment_method.text.match(/AUTHORIZED/i).nil?
      end

      def is_klarna_pending?
        !payment_method.text.match(/PENDING/i).nil?
      end

      def is_klarna_captured?
        !payment_method.text.match(/CAPTURED/i).nil?
      end

      def is_klarna_cancelled?
        !payment_method.text.match(/CANCELLED/i).nil?
      end

      def is_pending?
        !payment_state.text.match(/PENDING/i).nil?
      end

      def is_completed?
        !payment_state.text.match(/COMPLETED/i).nil?
      end

      def is_cancelled?
        !payment_state.text.match(/CANCELLED/i).nil?
      end

      def is_void?
        !payment_state.text.match(/VOID/i).nil?
      end

      def capture!
        Capybara.using_wait_time(CapybaraExtraWaitTime) do
          actions.find('[data-action="capture"]').click
        end
      end

      def extend!
        Capybara.using_wait_time(CapybaraExtraWaitTime) do
          actions.find('[data-action="extend_period"]').click
        end
      end

      def cancel!
        Capybara.using_wait_time(CapybaraExtraWaitTime) do
          actions.find('[data-action="cancel"]').click
        end
      end

      def refund!
        Capybara.using_wait_time(CapybaraExtraWaitTime) do
          if KlarnaGateway.is_solidus? || KlarnaGateway.up_to_spree?('2.4.99')
            actions.find('a.fa-reply').click
          else
            actions.find('a.action-refund').click
          end
        end
      end
    end

    class Payments < Base
      set_url '/admin/orders/{number}/payments'
      sections :payments, PaymentItem, 'table#payments tbody tr[data-hook="payments_row"]'


      if KlarnaGateway.is_solidus?
        section :menu, PageDrivers::Admin::OrderMenu, '.container nav ul.tabs'
        element :new_payment_button, '#content-header .header-actions #new_payment_section a'
      elsif KlarnaGateway.up_to_spree?('2.4.99')
        section :menu, PageDrivers::Admin::OrderMenu, 'aside#sidebar ul'
        element :new_payment_button, '#content-header .page-actions #new_payment_section a'
      else
        section :menu, PageDrivers::Admin::OrderMenu, 'aside#sidebar ul'
        element :new_payment_button, '.content-header .page-actions #new_payment_section a'
      end

      elements :refunds, 'tr[data-hook="refunds_row"]'
    end
  end
end
