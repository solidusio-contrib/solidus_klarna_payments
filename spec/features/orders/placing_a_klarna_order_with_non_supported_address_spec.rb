require 'features_helper'

describe 'Orders to non-supported countries', type: 'feature', bdd: true, no_klarna: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'gateway should be unavailable when shipping to a non-supported country' do
    product_name = 'Ruby on Rails Mug'
    product_quantity = 2

    on_the_home_page do |page|
      page.load
      expect(page.displayed?).to be(true)

      page.choose(product_name)
    end

    on_the_product_page do |page|
      page.wait_for_title
      expect(page.displayed?).to be(true)

      expect(page.title).to have_content(product_name)
      page.add_to_cart(product_quantity)
    end

    on_the_cart_page do |page|
      page.line_items
      expect(page.displayed?).to be(true)

      expect(page.line_items).to have_content(product_name)

      page.continue
    end

    on_the_registration_page do |page|
      expect(page.displayed?).to be(true)

      page.checkout_as_guest(@testing_data.ca_address.email)
    end

    on_the_address_page do |page|
      expect(page.displayed?).to be(true)
      page.set_address(@testing_data.ca_address)

      page.continue
    end

    on_the_delivery_page do |page|
      expect(page.displayed?).to be(true)
      page.stock_contents.each do |stocks|
        expect(stocks).to have_content(product_name)
      end
      page.continue
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_payment_method(@testing_data.payment_name).click

      page.klarna_credit do |frame|
        expect(frame).to have_content('Not available for this country')
      end

      page.select_payment_method('Check').click

      page.continue
    end

    on_the_confirm_page do |page|
      expect(page.displayed?).to be(true)

      page.continue
    end

    Capybara.current_session.driver.quit
  end
end

