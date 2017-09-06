require 'features_helper'

describe 'Cancelled Klarna Payments', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it "doesn't show klarna warning message with cancelled orders." do
    order_product(product_name: 'Ruby on Rails Bag', testing_data: @testing_data)
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

    on_the_admin_order_page.menu.customer.click

    on_the_admin_customer_page do |page|
      expect(page.displayed?).to be(true)

      expect(page).to have_content('Updates to this order will not be reflected in Klarna')
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

      page.new_payment_button.click
    end

    on_the_admin_new_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_check
      page.update_button.click
    end

    on_the_admin_payments_page do |page|
      expect(page.displayed?).to be(true)

      expect(page.payments.count).to be(2)
      expect(page.payments.second.is_check?).to be(true)

      page.menu.shipments.click
    end

    on_the_admin_order_page do |page|
      expect(page.displayed?).to be(true)
      expect(page).not_to have_content('Updates to this order will not be reflected in Klarna')

      page.menu.customer.click
    end

    on_the_admin_customer_page do |page|
      expect(page.displayed?).to be(true)

      expect(page).not_to have_content('Updates to this order will not be reflected in Klarna')
    end
  end
end
