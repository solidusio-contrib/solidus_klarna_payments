require 'features_helper'

describe 'Ordering with Klarna Payment Method' do
  include PageDrivers::CheckoutProcess

  it 'Buy 10 Ruby on Rails Bag with Klarna' do
    visit '/'
    product_name = 'Ruby on Rails Bag'

    on_the_home_page.choose(product_name)
    on_the_product_page.has_name?(product_name)
    on_the_product_page.add_to_cart(10)

    on_the_cart_page.has_item_by_name?(product_name)
    on_the_cart_page.continue

    on_the_registration_page.checkout_as_guest
    on_the_address_page.set_address(TestData::USAddress)
    on_the_address_page.continue

    on_the_delivery_page.has_item_by_name?(product_name)
    on_the_delivery_page.continue

    on_the_payment_page.select_check
    on_the_payment_page.continue

    on_the_confirm_page.wait_for_ajax
    on_the_confirm_page.continue

    on_the_complete_page.is_valid?
    on_the_complete_page.get_order_number
  end
end
