# frozen_string_literal: true

RSpec.describe 'Error handling', :js do
  it 'Selecting Klarna when token generation fails' do
    without_js_errors do
      create_and_stub_order
      setup_check
      setup_klarna
      simulate_klarna_token_generation_error

      visit spree.checkout_path

      on_the_payment_page do |payment_page|
        payment_page.load
        payment_page.select_payment_method('Klarna US').click

        expect(payment_page.klarna_error.text).to match(/A technical error has occurred./)
      end
    end
  end

  private

  def simulate_klarna_token_generation_error
    allow_any_instance_of(Spree::Order).to receive(:klarna_client_token).and_return('a')
  end

  def without_js_errors
    Capybara.current_driver = :apparition_without_js_errors
  ensure
    Capybara.use_default_driver
  end
end
