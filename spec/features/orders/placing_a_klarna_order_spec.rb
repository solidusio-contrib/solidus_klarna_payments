require 'features_helper'

describe 'Ordering with Klarna Payment Method', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  # This is only implemented for US
  it 'Denies the order from a banned user', only: :us do
    klarna_order = order_on_state(product_name: 'Ruby on Rails Bag', state: :delivery, quantity: 1, email: TestData::Users.denied)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_klarna(@testing_data)
      page.continue(@testing_data)

      page.klarna_credit do |frame|
        expect(frame).to have_content('Unable to approve application')
      end
    end

    Capybara.current_session.driver.quit
  end

  # Due to a bug in Solidus this test is currently not working
  # see https://github.com/solidusio/solidus/pull/542
  xit 'can change to a check payment before confirming the payment' do
    klarna_order = order_on_state(product_name: 'Ruby on Rails Bag', state: :delivery, quantity: 1)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_klarna(@testing_data) do |checkbox|
        expect(checkbox.checked?).to be(true)
      end

      page.continue(@testing_data)
    end

    on_the_confirm_page do |page|
      expect(page.displayed?).to be(true)

      page.change_payment
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_check do |checkbox|
        expect(checkbox.checked?).to be(true)
      end

      page.continue
    end

    on_the_confirm_page do |page|
      expect(page.displayed?).to be(true)

      page.continue
    end

    on_the_complete_page do |page|
      expect(page.displayed?).to be(true)

      expect(page.notice).to be_displayed

      page.get_order_number
    end
  end
end
