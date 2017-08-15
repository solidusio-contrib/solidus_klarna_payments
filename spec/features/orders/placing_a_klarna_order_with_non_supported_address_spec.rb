require 'features_helper'

describe 'Orders to non-supported countries', type: 'feature', bdd: true, no_klarna: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'gateway should be unavailable when shipping to a non-supported country' do
    @testing_data.address.city = "Paris"
    @testing_data.address.country = "France"
    @testing_data.address.state = "Île-de-France"
    order_product(product_name: 'Ruby on Rails Tote', testing_data: @testing_data)

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_payment_method('Klarna').click

      page.klarna_credit do |frame|
        expect(frame).to have_content('Not available for this country')
      end
    end
  end

  # TODO - REFACTOR THIS ASAP - 15/08/2017 - Tinus Wagner
  # Currently used to try debug why values are persisted in address form
  # between sessions & tests.
  it 'clears the session variables from the incompleted purchase' do
    visit home

    on_the_home_page do |page|
      Spree::Order.incomplete.delete_all
      expect(Spree::Order.incomplete.first).to be(empty)
      Capybara.reset_sessions!
      browser = Capybara.current_session.driver.browser
      if browser.respond_to?(:clear_cookies)
        # Rack::MockSession
        browser.clear_cookies
      elsif browser.respond_to?(:manage) and browser.manage.respond_to?(:delete_all_cookies)
        # Selenium::WebDriver
        browser.manage.delete_all_cookies
      else
        raise "Don't know how to clear cookies. Weird driver?"
      end
    end
  end
end
