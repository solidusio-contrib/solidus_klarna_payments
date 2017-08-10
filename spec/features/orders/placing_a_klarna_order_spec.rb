require 'features_helper'

describe 'Ordering with Klarna Payment Method', type: 'feature', bdd: true do
  include_context "ordering with klarna"

  it 'Buy 10 Ruby on Rails Bag with Klarna' do
    order_product('Ruby on Rails Bag')
    pay_with_klarna
  end

  it 'Denies the order from a banned user' do
    order_product('Ruby on Rails Bag', TestData::Users.denied)
    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_klarna
      page.continue

      page.klarna_credit do |frame|
        if $data.de?
          expect(frame).to have_content('Unable to approve application')
        else
          expect(frame).to have_content('Unable to approve application')
        end
      end
    end
  end

  it 'can change to a check payment before confirming the payment' do
    order_product('Ruby on Rails Bag')

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_klarna
      page.continue
    end

    on_the_confirm_page  do |page|
      expect(page.displayed?).to be(true)
      page.change_payment
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_check
      page.continue
    end

    on_the_confirm_page do |page|
      expect(page.displayed?).to be(true)

      page.continue
    end

    on_the_complete_page do |page|
      expect(page.displayed?).to be(true)

      if $data.de?
        expect(page.flash_message).to have_content('Ihre Bestellung wurde erfolgreich bearbeitet')
      else
        expect(page.flash_message).to have_content('Your order has been processed successfully')
      end

      page.get_order_number
    end
  end
end
