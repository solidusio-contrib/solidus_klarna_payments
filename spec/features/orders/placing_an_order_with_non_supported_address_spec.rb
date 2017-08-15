require 'features_helper'

describe 'Orders to non-supported countries', type: 'feature', bdd: true, no_klarna: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'gateway should be unavailable when shipping to a non-supported country' do
    @testing_data2 = @testing_data.dup
    @testing_data2.address.city = "Paris"
    @testing_data2.address.country = "France"
    @testing_data2.address.state = "Île-de-France"
    order_product(product_name: 'Ruby on Rails Bag', testing_data: @testing_data2)

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_payment_method('Klarna').click

      page.klarna_credit do |frame|
        expect(frame).to have_content('Not available for this country')
      end
    end
  end
end
