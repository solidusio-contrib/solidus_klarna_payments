require 'features_helper'

describe 'Disables Klarna payment options if the form is toggled false (US Specific)', type: 'feature', bdd: true  do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  # This is only implemented for US
  it 'Klarna form renders error instead of options (US Specific)', only: :us do
    @testing_data.address.email = TestData::Users.no_options_available
    order_product(product_name: 'Ruby on Rails Bag', testing_data: @testing_data)

    on_the_payment_page do |page|
      Capybara.using_wait_time(CapybaraExtraWaitTime) do
        expect(page.displayed?).to be(true)
        page.choose('Klarna US')
        wait_for_ajax

        page.klarna_credit do |frame|
          expect(frame).to have_content('Option not available') if @testing_data.us?
        end
      end
    end

    Capybara.current_session.driver.quit
  end
end
