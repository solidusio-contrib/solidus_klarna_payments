require 'features_helper'

describe 'Ordering with Klarna Payment Method' do
  include_context "ordering with klarna"

  it 'Buy 10 Ruby on Rails Bag with Klarna' do
    order_product('Ruby on Rails Bag')
    pay_with_klarna
  end
end
