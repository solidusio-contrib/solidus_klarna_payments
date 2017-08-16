require 'features_helper'

describe 'Ordering with Klarna Payment Method Using Discount', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'Creates a 10% discount code of total cost' do
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
      expect(page).to have_content('Promotion "code10%" has been successfully updated!')

      page.add_promotion
      wait_for_ajax
      page.complete_promotion_form
      page.update_action

      expect(page.displayed?).to be(true)
      expect(page).to have_content('Promotion "code10%" has been successfully updated!')


      binding.pry

    end
  end
end
