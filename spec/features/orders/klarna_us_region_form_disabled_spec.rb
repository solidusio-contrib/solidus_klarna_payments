require 'features_helper'

describe 'Disables Klarna payment options if the form is toggled false (US Specific)', type: 'feature', bdd: true  do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  # This is only implemented for US
  it 'Klarna form renders error instead of options (US Specific)', only: :us do
    klarna_order = order_on_state(product_name: 'Ruby on Rails Bag', state: :delivery, quantity: 1, email: TestData::Users.no_options_available)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.choose('Klarna US')
      wait_for_ajax

      page.klarna_credit do |frame|
        expect(frame).to have_content('Option not available') if @testing_data.us?
      end
    end

    Capybara.current_session.driver.quit
  end
end
