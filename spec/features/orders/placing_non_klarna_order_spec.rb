require 'features_helper'

describe 'Orders with non-klarna payment method renders legacy checkout', type: 'feature', bdd: true, no_klarna: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'Should not render the klarna iframe if check is payment method' do
    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data)

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_payment_method("Check").click

      expect(page).not_to have_selector('iframe')
      page.continue
    end

    on_the_complete_page do |page|
      expect(page.displayed?).to be(true)
      expect(page.notice).to be_displayed
    end
  end
end
