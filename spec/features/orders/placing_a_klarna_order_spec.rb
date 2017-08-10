require 'features_helper'

describe 'Ordering with Klarna Payment Method', type: 'feature', bdd: true do
  include_context "ordering with klarna"

  it 'Buy 10 Ruby on Rails Bag with Klarna' do
    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data)
    pay_with_klarna(testing_data: @testing_data)
  end

  it 'Denies the order from a banned user' do
    order_product(product_name:  'Ruby on Rails Bag', email: TestData::Users.denied, testing_data: @testing_data)
    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_klarna(@testing_data)
      page.continue(@testing_data)

      page.klarna_credit do |frame|
        if @testing_data.de?
          expect(frame).to have_content('Unable to approve application')
        else
          expect(frame).to have_content('Unable to approve application')
        end
      end
    end
  end

  xit 'can change to a check payment before confirming the payment' do
    order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data)

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_klarna(@testing_data)
      page.continue(@testing_data)
    end

    on_the_confirm_page  do |page|
      expect(page.displayed?).to be(true)
      page.change_payment
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_check
      page.continue(@testing_data)
    end

    on_the_confirm_page do |page|
      expect(page.displayed?).to be(true)

      page.continue
    end

    on_the_complete_page do |page|
      expect(page.displayed?).to be(true)

      if @testing_data.de?
        expect(page.flash_message).to have_content('Ihre Bestellung wurde erfolgreich bearbeitet')
      else
        expect(page.flash_message).to have_content('Your order has been processed successfully')
      end

      page.get_order_number
    end
  end
end
