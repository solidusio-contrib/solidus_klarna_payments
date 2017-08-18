require 'features_helper'

describe 'Ordering with Klarna Payment Method Using Discount', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'Creates a 10% discount code in the admin section' do
    on_the_admin_login_page do |page|
      page.load
      expect(page.displayed?).to be(true)

      expect(page.title).to have_content('Admin Login')
      page.login_with(TestData::AdminUser)
    end

    on_the_admin_promotions_page do |page|
      page.load
      expect(page.displayed?).to be(true)

      page.new_promotion
    end

    on_the_admin_new_promotion_page do |page|
      page.load
      expect(page.displayed?).to be(true)
      
      page.complete_form
      page.continue
    end

    on_the_admin_promotion_page do |page|
      expect(page.displayed?).to be(true)

      page.add_rule
      wait_for_ajax
      page.complete_rule_form
      page.update_rule

      expect(page.displayed?).to be(true)
      expect(page).to have_content('Promotion "test" has been successfully updated!')

      page.add_action
      wait_for_ajax
      page.complete_promotion_form
      page.update_action

      expect(page.displayed?).to be(true)
      expect(page).to have_content('Promotion "test" has been successfully updated!')
    end
    expect(Spree::Promotion.last.description).to eq('test')
  end

  it 'Klarna Purchase is made using the discount code' do
    discount_code = Spree::Promotion.last.codes.first.value

    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data, discount_code: discount_code)

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_klarna(@testing_data)
      page.continue(@testing_data)
    end

    on_the_confirm_page do |page|
      expect(page.displayed?).to be(true)

      order = Spree::Order.last
      promo_total = order.promo_total.to_f
      item_total = order.item_total.to_f

      expect(page).to have_content(item_total)
      # Multiply by -1 to flip to positive number
      expect(page).to have_content(promo_total*-1)
      expect(page).to have_content(order.total)
      page.continue
    end

    on_the_complete_page do |page|
      expect(page.displayed?).to be(true)
    end
  end

  it 'Discounted Klarna Purchase Is Confirmed in Admin Section' do
    order = Spree::Order.last
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

      expect(page).to have_content(order.total)

      page.payments.first.capture!
      wait_for_ajax

      expect(page.payments.first.is_klarna_captured?).to be(true)
      expect(page.payments.first.is_completed?).to be(true)
      page.payments.first.identifier.find('a').click
    end
  end
end
