require 'site_prism'
require 'support/pages/cart_page'
require 'support/pages/home_page'
require 'support/pages/product_page'
require 'support/pages/login_page'
require 'support/pages/checkout/registration_page'
require 'support/pages/checkout/address_page'
require 'support/pages/checkout/delivery_page'
require 'support/pages/checkout/payment_page'
require 'support/pages/checkout/confirm_page'
require 'support/pages/admin/order_page'
require 'support/pages/admin/order_payments_page'

RSpec.shared_context "page objects" do
  let(:product_page) { ProductPage.new }
  let(:cart_page) { CartPage.new }
  let(:registration_page) { Checkout::RegistrationPage.new }
  let(:address_page) { Checkout::AddressPage.new }
  let(:delivery_page) { Checkout::DeliveryPage.new }
  let(:payment_page) { Checkout::PaymentPage.new }
  let(:confirm_page) { Checkout::ConfirmPage.new }
  let(:login_page) { LoginPage.new }
  let(:order_page) { Admin::OrderPage.new }
  let(:order_payments_page) { Admin::OrderPaymentsPage.new }
end

RSpec.configure do |config|
  config.around(:each, :without_vcr) do |example|
    WebMock.allow_net_connect!
    VCR.turned_off { example.run }
    WebMock.disable_net_connect!
  end
end
