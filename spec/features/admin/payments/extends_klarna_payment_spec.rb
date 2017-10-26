require 'features_helper'

describe 'Managing a Klarna Payment', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include_context "change driver"
  include WorkflowDriver::Process

  # TODO 21/08/2017 Tinus Wagner
  # Leave this here until Klarna can give us a test email address to use with this spec
  xit 'Extends a Klarna Payment' do
    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data)
    pay_with_klarna(testing_data: @testing_data)

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

    on_the_admin_payments_page do |page|
      page.load(number: order.number)
      expect(page.displayed?).to be(true)

      expect(page.payments.first.is_klarna?).to be(true)
      expect(page.payments.first.is_pending?).to be(true)
      expect(page.payments.first.is_klarna_authorized?).to be(true)

      page.payments.first.extend!
    end
  end

  unless KlarnaGateway.up_to_spree?('2.3.99')
    it 'Refunds a Klarna Payment' do
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

      on_the_admin_payments_page do |page|
        page.load(number: order.number)
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
  end
end
