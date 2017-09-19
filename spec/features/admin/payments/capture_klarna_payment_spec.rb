require 'features_helper'

describe 'Managing a Klarna Payment', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'Captures a klarna payment' do
    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data)
    pay_with_klarna(testing_data: @testing_data)

    on_the_admin_login_page do |page|
      page.load
      expect(page.displayed?).to be(true)

      expect(page.title).to have_content('Admin Login')
      page.login_with(TestData::AdminUser)
    end

    on_the_admin_orders_page do |page|
      page.load
      expect(page.displayed?).to be(true)

      page.select_first_order
    end

    on_the_admin_order_page.menu.payments.click

    on_the_admin_payments_page do |page|
      expect(page.displayed?).to be(true)

      expect(page.payments.first.is_klarna?).to be(true)
      expect(page.payments.first.is_pending?).to be(true)
      expect(page.payments.first.is_klarna_authorized?).to be(true)

      page.payments.first.capture!
      expect(page.payments.first.is_klarna_captured?).to be(true)
      expect(page.payments.first.is_completed?).to be(true)
      page.payments.first.identifier.find('a').click
    end


    on_the_admin_payment_page.payment_menu.logs.click

    on_the_admin_logs_page do |page|
      expect(page.displayed?).to be(true)
      expect(page.log_entries.count).to eq(2)
      expect(page.log_entries.first.message.text).to have_content('Placed order')
      expect(page.log_entries.second.message.text).to have_content('Captured order')
    end

  end

  it 'Displays the Klarna Order ID in the Backend' do
    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data)
    pay_with_klarna(testing_data: @testing_data)

    on_the_admin_login_page do |page|
      page.load
      expect(page.displayed?).to be(true)

      expect(page.title).to have_content('Admin Login')
      page.login_with(TestData::AdminUser)
    end

    on_the_admin_orders_page do |page|
      page.load
      expect(page.displayed?).to be(true)

      page.select_first_order
    end

    on_the_admin_order_page.menu.payments.click

    klarna_order_id = Spree::Order.last.klarna_order_id


    on_the_admin_payments_page do |page|
      expect(page.displayed?).to be(true)

      expect(page.payments.first.is_klarna?).to be(true)
      expect(page.payments.first.is_pending?).to be(true)
      expect(page.payments.first.is_klarna_authorized?).to be(true)
      expect(page.payments.first).to have_content(klarna_order_id)

      page.payments.first.capture!
      expect(page.payments.first.is_klarna_captured?).to be(true)
      expect(page.payments.first.is_completed?).to be(true)
      page.payments.first.identifier.find('a').click
    end


    on_the_admin_payment_page.payment_menu.logs.click

    on_the_admin_logs_page do |page|
      expect(page.displayed?).to be(true)
      expect(page.log_entries.first.message.text).to have_content(klarna_order_id)
    end

  end

  it 'Cancels a Klarna Payment' do
    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data)
    pay_with_klarna(testing_data: @testing_data)

    on_the_admin_login_page do |page|
      page.load
      expect(page.displayed?).to be(true)

      expect(page.title).to have_content('Admin Login')
      page.login_with(TestData::AdminUser)
    end

    on_the_admin_orders_page do |page|
      page.load
      expect(page.displayed?).to be(true)
      page.select_first_order
    end

    on_the_admin_order_page.menu.payments.click

    on_the_admin_payments_page do |page|
      expect(page.displayed?).to be(true)

      expect(page.payments.first.is_klarna?).to be(true)
      expect(page.payments.first.is_pending?).to be(true)
      expect(page.payments.first.is_klarna_authorized?).to be(true)

      page.payments.first.cancel!

      expect(page.payments.first.is_klarna_cancelled?).to be(true)
      expect(page.payments.first.is_void?).to be(true)
      page.payments.first.identifier.find('a').click
    end

    on_the_admin_payment_page.payment_menu.logs.click

    on_the_admin_logs_page do |page|
      expect(page.displayed?).to be(true)

      expect(page.log_entries.count).to eq(2)
      expect(page.log_entries.first.message.text).to have_content('Placed order')
      expect(page.log_entries.second.message.text).to have_content('Cancelled order')
    end
  end

  # TODO 21/08/2017 Tinus Wagner
  # Leave this here until Klarna can give us a test email address to use with this spec
  xit 'Extends a Klarna Payment' do
    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data)
    pay_with_klarna(testing_data: @testing_data)

    on_the_admin_login_page do |page|
      page.load
      expect(page.displayed?).to be(true)

      expect(page.title).to have_content('Admin Login')
      page.login_with(TestData::AdminUser)
    end

    on_the_admin_orders_page do |page|
      page.load
      expect(page.displayed?).to be(true)
      page.select_first_order
    end

    on_the_admin_order_page.menu.payments.click

    on_the_admin_payments_page do |page|
      expect(page.displayed?).to be(true)

      expect(page.payments.first.is_klarna?).to be(true)
      expect(page.payments.first.is_pending?).to be(true)
      expect(page.payments.first.is_klarna_authorized?).to be(true)

      page.payments.first.extend!
    end
  end

  it 'Refunds a Klarna Payment' do
    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data)
    pay_with_klarna(testing_data: @testing_data)

    on_the_admin_login_page do |page|
      page.load
      expect(page.displayed?).to be(true)

      expect(page.title).to have_content('Admin Login')
      page.login_with(TestData::AdminUser)
    end

    on_the_admin_orders_page do |page|
      page.load
      expect(page.displayed?).to be(true)
      page.select_first_order
    end

    on_the_admin_order_page.menu.payments.click

    on_the_admin_payments_page do |page|
      expect(page.displayed?).to be(true)

      expect(page.payments.first.is_klarna?).to be(true)
      expect(page.payments.first.is_pending?).to be(true)
      expect(page.payments.first.is_klarna_authorized?).to be(true)

      page.payments.first.capture!
      expect(page.payments.first.is_klarna_captured?).to be(true)
      expect(page.payments.first.is_completed?).to be(true)

      expect(page).not_to have_content(/REFUNDS/i)

      page.payments.first.refund!
    end

    order_amount = Spree::Order.last.total.to_s

    on_the_admin_order_payments_refunds_page do |page|
      expect(page.displayed?).to be(true)
      page.select_reason!
      page.continue
    end

    on_the_admin_payments_page do |page|
      expect(page.displayed?).to be(true)
      refund_amount = Spree::Refund.last.amount.to_s
      expect(page).to have_content(/REFUNDS/i)
      expect(page.refunds.count).to eq(1)
      expect(order_amount).to eq(refund_amount)
    end
  end

  it 'Refresh a Klarna Payment'
end
