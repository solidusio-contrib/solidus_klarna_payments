require 'features_helper'

describe 'Managing a Klarna Payment', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'Displays the Klarna Order ID in the Backend' do
    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data)
    pay_with_klarna(testing_data: @testing_data)

    if KlarnaGateway.is_solidus?
      on_the_confirm_page do |page|
        expect(page.displayed?).to be(true)

        wait_for_ajax
        page.continue
      end
    end

    on_the_complete_page do |page|
      expect(page.displayed?).to be(true)
      page.get_order_number
    end

    on_the_admin_login_page do |page|
      page.load
      expect(page.displayed?).to be(true)

      page.login_with(TestData::AdminUser)
    end

    order = Spree::Order.complete.last
    klarna_order_id = order.klarna_order_id

    on_the_admin_payments_page do |page|
      page.load(number: order.number)
      expect(page.displayed?).to be(true)

      expect(page.payments.first.is_klarna?).to be(true)
      expect(page.payments.first.is_pending?).to be(true)
      expect(page.payments.first.is_klarna_authorized?).to be(true)

      unless KlarnaGateway.up_to_spree?('2.3.99')
        expect(page.payments.first).to have_content(klarna_order_id)
      end

      page.payments.first.capture!
      expect(page.payments.first.is_klarna_captured?).to be(true)
      expect(page.payments.first.is_completed?).to be(true)
      page.payments.first.identifier.find('a').click
    end


    on_the_admin_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.payment_menu.logs.click
    end

    on_the_admin_logs_page do |page|
      expect(page.displayed?).to be(true)
      expect(page.log_entries.first.message.text).to have_content(klarna_order_id)
    end
  end
end
