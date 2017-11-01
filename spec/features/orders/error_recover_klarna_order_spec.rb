require 'features_helper'

describe 'Rescue from an authorization error', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'Buy Ruby on Rails Bag with Klarna' do

    expect_any_instance_of(Spree::Order).to receive(:klarna_client_token).at_least(:once).and_return(nil)

    klarna_order = order_on_state(product_name: 'Ruby on Rails Bag', state: :delivery, quantity: 1)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_payment_method(@testing_data.payment_name).click

      expect(page.klarna_error.text).to match /A technical error has occurred./
    end

    Capybara.current_session.driver.quit
  end
end
