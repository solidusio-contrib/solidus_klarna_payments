module WorkflowDriver
  module Admin
    module PaymentManagement

      def on_the_admin_login_page
        @admin_login ||= PageDrivers::Admin::Login.new(page)
      end

      def on_the_admin_payments_page
        @admin_payments ||= PageDrivers::Admin::Payments.new(page)
      end

      def on_the_admin_payment_page
        @admin_payment ||= PageDrivers::Admin::Payment.new(page)
      end

      def on_the_admin_orders_page
        @admin_orders ||= PageDrivers::Admin::Orders.new(page)
      end

      def on_the_admin_order_page
        @admin_order ||= PageDrivers::Admin::Order.new(page)
      end

      def on_the_admin_logs_page
        @admin_log ||= PageDrivers::Admin::Logs.new(page)
      end
    end
  end
end
