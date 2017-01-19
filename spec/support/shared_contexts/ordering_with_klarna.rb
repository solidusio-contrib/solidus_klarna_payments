shared_context "ordering with klarna" do
  include WorkflowDriver::CheckoutProcess
  def order_product(product_name, email = "test@test.com")
    visit '/'

    on_the_home_page.choose(product_name)
    on_the_product_page.has_name?(product_name)
    on_the_product_page.add_to_cart(10)

    on_the_cart_page.has_item_by_name?(product_name)
    on_the_cart_page.continue

    on_the_registration_page.checkout_as_guest(email)
    on_the_address_page.set_address($data.address)
    on_the_address_page.continue

    on_the_delivery_page.has_item_by_name?(product_name)
    on_the_delivery_page.continue
  end

  def pay_with_klarna
    on_the_payment_page.select_klarna
    on_the_payment_page.continue

    on_the_confirm_page.wait_for_reauthorization
    on_the_confirm_page.continue

    on_the_complete_page.is_valid?
    on_the_complete_page.get_order_number
  end
end


