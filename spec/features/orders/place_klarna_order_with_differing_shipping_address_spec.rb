require 'features_helper'

describe 'Ordering with Klarna Payment using differing payment/shipping addresses', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  # Test will fail since this has not been implemented on the Klarna side yet
  xit 'renders error when payment shipping first & last names differ' do
    klarna_order = order_on_state(product_name: 'Ruby on Rails Bag', state: :delivery, quantity: 1, differing_delivery_addrs: true)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_klarna(@testing_data)

      page.klarna_credit do |frame|
        expect(frame).to have_content('Unable to approve application')
      end
    end
  end
end
