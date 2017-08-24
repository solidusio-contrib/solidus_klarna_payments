require 'features_helper'

describe 'Altering order of payment options in checkout', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'Changes the order of payment options - Puts Klarna first' do
    gateway = Spree::PaymentMethod.where("name LIKE :prefix", prefix: "#{Klarna}%").first
    gateway.position = 1
    gateway.save
    expect(gateway.position).to eq(1)

    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data)

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      expect(page.payment_methods.first).to have_content('Klarna')
    end
  end
end
