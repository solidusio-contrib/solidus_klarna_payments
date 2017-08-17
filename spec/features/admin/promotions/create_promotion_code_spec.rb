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
    random = rand(Spree::Promotion.last.codes.count)
    discount_code = Spree::Promotion.last.codes.offset(random).first.value

    order_product(
      product_name:  'Ruby on Rails Bag',
      testing_data: @testing_data,
      discount_code: discount_code
    )
    pay_with_klarna(testing_data: @testing_data)

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      order = Spree::Order.last

      promo_total = order.promo_total.to_f
      item_total = order.item_total.to_f

      new_total = (item_total - promo_total)
      expect(page).to have_content(item_total)
      expect(page).to have_content(promo_total)
      expect(page).to have_content(new_total)
    end
  end
end
