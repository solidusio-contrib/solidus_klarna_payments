shared_context "ordering with klarna" do
  include WorkflowDriver::Process
  include RSpec::Matchers
  include Capybara::RSpecMatchers

  def order_product(options)
    product_name = options.fetch(:product_name, 'Ruby on Rails Bag')
    testing_data = options.fetch(:testing_data)
    product_quantity = options.fetch(:product_quantity, 2)
    email = options.fetch(:email) { testing_data.address.email }


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
      if options[:discount_code]
        discount_code = options.fetch(:discount_code)
        page.add_coupon_code(discount_code)

        expect(page.displayed?).to be(true)
        expect(page.adjustment).to have_content('Adjustment: Promotion')
      end

      expect(page.line_items).to have_content(product_name)
      page.continue
    end

    on_the_registration_page do |page|
      expect(page.displayed?).to be(true)

      page.checkout_as_guest(email)
    end

    on_the_address_page do |page|
      expect(page.displayed?).to be(true)
      page.set_address(testing_data.address)

      page.continue
    end

    on_the_delivery_page do |page|
      expect(page.displayed?).to be(true)
      page.stock_contents.each do |stocks|
        expect(stocks).to have_content(product_name)
      end
      page.continue
    end
  end

  def select_klarna_payment(testing_data)
    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_klarna(testing_data)
      page.continue(testing_data)
    end
  end

  def pay_with_klarna(options)
    testing_data = options.fetch(:testing_data)

    select_klarna_payment(testing_data)

    confirm_on_local
  end

  def confirm_on_local
    on_the_confirm_page do |page|
      expect(page.displayed?).to be(true)

      wait_for_ajax
      page.continue
    end
  end

  def confirm_on_remote
    on_the_confirm_page do |page|
      expect(page.displayed?).to be(true)

      wait_for_ajax
      page.continue
    end

    on_the_complete_page do |page|
      expect(page.displayed?).to be(true)

      if testing_data.de?
        expect(page.flash_message).to have_content('Ihre Bestellung wurde erfolgreich bearbeitet')
      else
        expect(page.flash_message).to have_content('Your order has been processed successfully')
      end

      expect(page.order_number.text).to match(/Order|Bestellnummer /)
      page.get_order_number
    end
  end
end
