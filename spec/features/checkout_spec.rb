require "spec_helper"

feature "Checkout", :without_vcr do
  include_context "page objects"

  let!(:product) { create(:product) }
  let!(:shipping_method) { create(:shipping_method) }
  let!(:payment_method) { create(:payment_method) }
  let!(:payment_method) { create(:klarna_credit_payment_method) }
  let!(:store) { create(:store) }
  let!(:admin) { create(:admin_user) }
  let(:address) { build(:address, lastname: "Doe") }

  scenario "Successfully order a product with Klarna Payment", js: true do
    product_page.load(slug: product.slug)
    product_page.cart_button.click

    cart_page.checkout_button.click

    registration_page.customer_email_field.set "mail@example.com"
    registration_page.continue_button.click

    address_page.billing_address.set address
    expect(address_page.shipping_address).to be_using_billing_address
    address_page.continue_button.click

    delivery_page.continue_button.click

    payment_page.wait_for_klarna_payment
    payment_page.klarna_payment do |payment|
      payment.wait_for_payment_options
      # Need trigger here
      payment.payment_options.first.trigger("click")
    end
    payment_page.continue_button.click

    expect(confirm_page).to be_displayed
    expect {
      confirm_page.continue_button.click
    }.to change{Spree::Order.complete.count}.by(1)

    login_page.load
    login_page.login(admin, "secret")

    order_payments_page.load(number: Spree::Order.complete.last.number)
    order_payments_page.payments.first.capture
    expect(order_payments_page.payments.first).to be_captured
  end
end
