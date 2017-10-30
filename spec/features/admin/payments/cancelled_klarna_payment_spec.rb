require 'features_helper'

describe 'Cancelled Klarna Payments', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include_context "change driver"
  include WorkflowDriver::Process

  it "doesn't show klarna warning message with cancelled orders." do
    klarna_order = order_on_state(product_name: 'Ruby on Rails Bag', state: :delivery, quantity: 1)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    pay_with_klarna(testing_data: @testing_data)

    if KlarnaGateway.is_solidus?
      on_the_confirm_page do |page|
        expect(page.displayed?).to be(true)
      end
    else
      on_the_complete_page do |page|
        expect(page.displayed?).to be(true)
      end
    end

    expect(klarna_order.confirm?).to be(true)
    klarna_order.complete
    expect(klarna_order.complete?).to be(true)

    Capybara.current_session.driver.quit

    change_driver_to(:poltergeist) do
      on_the_admin_login_page do |page|
        page.load
        expect(page.displayed?).to be(true)

        page.login_with(TestData::AdminUser)
      end

      on_the_admin_customer_page do |page|
        page.load(number: klarna_order.number)
        expect(page.displayed?).to be(true)

        expect(page).to have_content('Updates to this order will not be reflected in Klarna')
      end

      on_the_admin_payments_page do |page|
        page.load(number: klarna_order.number)
        expect(page.displayed?).to be(true)
        expect(page.payments.first.is_klarna?).to be(true)
        expect(page.payments.first.is_pending?).to be(true)
        expect(page.payments.first.is_klarna_authorized?).to be(true)
        page.payments.first.cancel!
        expect(page.payments.first.is_klarna_cancelled?).to be(true)

        unless KlarnaGateway.up_to_spree?('2.3.99')
          expect(page.payments.first.is_void?).to be(true)
        end

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
end
