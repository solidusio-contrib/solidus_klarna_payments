# frozen_string_literal: true

RSpec.describe 'Payment management', :js do
  stub_authorization!

  it 'Capturing a Klarna payment' do
    order = place_order_with_klarna
    payment = order.payments.find_by(source_type: 'Spree::KlarnaCreditPayment')

    expect do
      on_the_admin_payments_page do |page|
        page.load(number: order.number)
        page.payments.first.capture!
      end

      payment.reload
    end.to change(payment, :state).to('completed')
  end

  it 'Refunding a Klarna payment' do
    order = place_order_with_klarna
    payment = order.payments.find_by(source_type: 'Spree::KlarnaCreditPayment')

    expect do
      on_the_admin_payments_page do |page|
        page.load(number: order.number)
        page.payments.first.capture!
        page.payments.first.refund!
      end

      payment.reload
    end.to change(payment, :state).to('completed')
  end

  private

  def place_order_with_klarna
    order = create_and_stub_order
    setup_check
    setup_klarna

    visit spree.checkout_path

    on_the_payment_page do |payment_page|
      payment_page.load
      payment_page.select_klarna
      payment_page.continue
    end

    on_the_confirm_page(&:continue)

    on_the_complete_page do |complete_page|
      complete_page.wait_until_order_number_visible
      expect(complete_page.displayed?).to eq(true)
    end

    order
  end
end
