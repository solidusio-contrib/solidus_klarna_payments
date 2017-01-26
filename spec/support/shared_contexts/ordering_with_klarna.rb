shared_context "ordering with klarna" do
  include WorkflowDriver::Process
  include RSpec::Matchers
  include Capybara::RSpecMatchers

  def order_product(product_name, email = "test@test.com")
    on_the_home_page do |page|
      page.load
      expect(page.displayed?).to be(true)

      page.choose(product_name)
    end

    on_the_product_page do |page|
      page.wait_for_title
      expect(page.displayed?).to be(true)

      expect(page.title).to have_content(product_name)
      page.add_to_cart(10)
    end

    on_the_cart_page do |page|
      page.line_items
      expect(page.displayed?).to be(true)

      expect(page.line_items).to have_content(product_name)
      page.continue
    end

    on_the_registration_page do |page|
      expect(page.displayed?).to be(true)

      page.checkout_as_guest(email)
    end

    on_the_address_page do |page|
      expect(page.displayed?).to be(true)

      page.set_address($data.address)
      page.continue
    end

    on_the_delivery_page do |page|
      expect(page.displayed?).to be(true)

      expect(page.stock_contents).to have_content(product_name)
      page.continue
    end
  end

  def pay_with_klarna
    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_klarna
      page.continue
    end

    on_the_confirm_page do |page|
      expect(page.displayed?).to be(true)

      wait_for_ajax
      page.continue
    end

    on_the_complete_page do |page|
      expect(page.displayed?).to be(true)

      if $data.de?
        expect(page.flash_message).to have_content('Ihre Bestellung wurde erfolgreich bearbeitet')
      else
        expect(page.flash_message).to have_content('Your order has been processed successfully')
      end

      expect(page.order_number.text).to match(/Order|Bestellnummer /)
      page.get_order_number
    end
  end
end


