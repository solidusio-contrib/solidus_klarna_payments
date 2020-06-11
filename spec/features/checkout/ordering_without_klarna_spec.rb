# frozen_string_literal: true

RSpec.describe 'Ordering without Klarna', :js do
  it 'Completing the checkout flow' do
    create_and_stub_order
    setup_klarna
    setup_check

    visit spree.checkout_path

    on_the_payment_page do |payment_page|
      payment_page.load
      payment_page.select_payment_method('Check').click
      payment_page.continue
    end

    on_the_confirm_page(&:continue)

    on_the_complete_page do |complete_page|
      expect(complete_page.displayed?).to eq(true)
    end
  end
end
