require 'features_helper'

describe 'Rescue from an authorization error', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'Buy Ruby on Rails Bag with Klarna' do
    expect(Spree::PaymentMethod).to receive(:find_by).with(any_args).at_least(:once).and_return(Spree::PaymentMethod.find_by_name("Wrong Klarna"))
    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data)

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_payment_method('Wrong Klarna').click

      expect(page.klarna_error.text).to match /A technical error has occurred./
    end
  end
end
