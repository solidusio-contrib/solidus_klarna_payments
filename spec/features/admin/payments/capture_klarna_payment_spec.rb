require 'features_helper'

describe 'Managing a Klarna Payment' do
  include_context "ordering with klarna"
  include WorkflowDriver::Admin::PaymentManagement

  it 'Captures a klarna payment' do
    order_product('Ruby on Rails Bag')
    pay_with_klarna

    visit '/admin/login'
    on_the_admin_login_page.login_with(TestData::AdminUser)

    on_the_admin_orders_page.visit
    on_the_admin_orders_page.select_first_order
    on_the_admin_orders_page.visit_payments

    on_the_admin_payments_page.is_klarna?
    on_the_admin_payments_page.is_pending?
    on_the_admin_payments_page.is_klarna_authorized?
    on_the_admin_payments_page.capture

    on_the_admin_payments_page.is_klarna_captured?
    on_the_admin_payments_page.is_completed?

    on_the_admin_payments_page.show_first_payment

    on_the_admin_payment_page.click_logs

    on_the_admin_logs_page.has_logs?(2)
    on_the_admin_logs_page.has_authorization_log?
    on_the_admin_logs_page.has_capture_log?

  end

  it 'Refunds a Klarna Payment'
  it 'Cancels a Klarna Payment'
  it 'Refresh a Klarna Payment'
  it 'Extends a Klarna Payment'
end
