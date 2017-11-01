require 'features_helper'

describe 'renders Klarna logos on checkout', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'renders the main img logo from the CDN after klarna is selected' do
    klarna_order = order_on_state(product_name: 'Ruby on Rails Bag', state: :delivery, quantity: 1)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    Capybara.using_wait_time(CapybaraExtraWaitTime) do
      on_the_payment_page do |page|
        expect(page.displayed?).to be(true)
        page.select_klarna(@testing_data)
        expect(page).to have_selector("img[src$='https://cdn.klarna.com/1.0/shared/image/generic/logo/en_us/basic/white.png?width=80']", visible: true)

        page.continue(@testing_data)
      end
    end

    Capybara.current_session.driver.quit
  end

  it 'renders the footer svg logo from the CDN after klarna is selected' do
    klarna_order = order_on_state(product_name: 'Ruby on Rails Bag', state: :delivery, quantity: 1)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    Capybara.using_wait_time(CapybaraExtraWaitTime) do
      on_the_payment_page do |page|
        expect(page.displayed?).to be(true)
        page.select_klarna(@testing_data)

        page.klarna_credit do |frame|
          expect(frame).to have_css('svg._1Qyng')
        end

        page.continue(@testing_data)
      end
    end

    Capybara.current_session.driver.quit
  end
end
