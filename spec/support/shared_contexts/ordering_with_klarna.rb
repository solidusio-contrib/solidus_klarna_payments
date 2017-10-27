shared_context "ordering with klarna" do
  include WorkflowDriver::Process
  include RSpec::Matchers
  include Capybara::RSpecMatchers

  def order_product(options)
    product_name = options.fetch(:product_name, 'Ruby on Rails Bag')
    testing_data = options.fetch(:testing_data)
    product_quantity = options.fetch(:product_quantity, 2)
    email = options.fetch(:email) { testing_data.address.email }
    discount_code = options.fetch(:discount_code, nil)



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

  def order_on_state(product_name: product_name, state: state, quantity: quantity, email: "spree@example.com", alternative_address: nil, promotion: nil, differing_delivery_addrs: false)
    user = create(:user)

    order = KlarnaOrderWalkthrough.new(product_name: product_name, state: state, quantity: quantity, email: email, alternative_address: alternative_address, differing_delivery_addrs: differing_delivery_addrs).call
    order.reload
    order.user = user
    order.update!

    if promotion
      promotion_code = if KlarnaGateway.is_spree?
                        Spree::Promotion.last.code
                      else
                        Spree::Promotion.last.codes.first
                      end
      Spree::OrderPromotion.create!(promotion: promotion, order: order, promotion_code: promotion_code)
      promotion.actions.each do |action|
        action.perform({ order: order, promotion: promotion, promotion_code: promotion_code })
      end
    end

    allow_any_instance_of(Spree::Klarna::SessionsController).to receive_messages(current_order: order)
    allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)
    allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: user)

    order.reload.update!
    order
  end
end
