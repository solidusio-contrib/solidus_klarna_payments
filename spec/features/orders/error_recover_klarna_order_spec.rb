require 'features_helper'

describe 'Rescue from an authorization error', type: 'feature' do
  include_context "ordering with klarna"

  it 'Buy 10 Ruby on Rails Bag with Klarna' do
    expect(Klarna).to receive(:client).with(:credit).and_raise("boom")
    order_product('Ruby on Rails Bag')
    binding.pry

    select_klarna_payment
  end
end
