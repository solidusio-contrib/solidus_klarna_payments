require 'features_helper'

describe 'Disables Klarna payment options if the form is toggled false (US Specific)', type: 'feature', bdd: true  do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'Klarna form renders error instead of options (US Specific)' do
    @testing_data.address.email = TestData::Users.no_options_available
    order_product(product_name: 'Ruby on Rails Bag', testing_data: @testing_data)

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.choose('Klarna US')
      wait_for_ajax

      # Todo 16/08/2017 Tinus Wagner
      # Perhaps the if statement can be moved to a tag?
      page.klarna_credit do |frame|
        expect(frame).to have_content('Option not available') if @testing_data.country == "us_address"
      end
    end
  end
end
