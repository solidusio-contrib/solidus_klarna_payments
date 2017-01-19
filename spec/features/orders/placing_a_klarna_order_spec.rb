require 'features_helper'

describe 'Ordering with Klarna Payment Method' do
  include_context "ordering with klarna"

  it 'Buy 10 Ruby on Rails Bag with Klarna' do
    order_product('Ruby on Rails Bag')
    pay_with_klarna
  end

  it 'Denies the order from a banned user' do
    order_product('Ruby on Rails Bag', TestData::Users.denied)
    on_the_payment_page.select_klarna
    on_the_payment_page.continue
    on_the_payment_page.is_klarna_unappoved?
  end

  it 'can change to a check payment before confirming the payment' do
    order_product('Ruby on Rails Bag')
    on_the_payment_page.select_klarna
    on_the_payment_page.continue

    on_the_confirm_page.change_payment

    on_the_payment_page.select_check
    on_the_payment_page.continue

    on_the_confirm_page.continue
    on_the_complete_page.is_valid?
    on_the_complete_page.get_order_number
  end
end
