# frozen_string_literal: true

module PageDrivers
  class KlarnaCredit < SitePrism::Page
    elements :options, 'label'
    element :klarna_credit_logo, "#klarna-logo"
    element :total_amount, "#combined-account-details-content-total__content"
  end

  class KlarnaCreditFullscreen < SitePrism::Page
    element :date_field, "#purchase-approval-date-of-birth__input"
    element :agreement_field, "#purchase-approval-accept-terms-input__label"
    element :continue_button, "button#purchase-approval-continue-button"
    element :klarna_credit_logo, "#klarna-logo"
  end

  class Payment < Base
    set_url "/checkout/payment"

    elements :payment_methods, "#payment #payment-method-fields label"
    element :klarna_error, ".klarna_error"
    element :klarna_credit_logo, "#klarna-logo"
    element :order_coupon_code, "#payment #order_coupon_code"
    element :summary, '[data-hook="order_summary"]'

    element :continue_button, 'form#checkout_form_payment input.continue'

    iframe :klarna_credit, KlarnaCredit, '#klarna-credit-main'
    iframe :klarna_credit_fullscreen, KlarnaCreditFullscreen, '#klarna-credit-fullscreen'

    def select_payment_method(name)
      payment_methods.find{ |e| e.text == name }
    end

    def select_klarna(&block)
      Capybara.using_wait_time(60) do
        select_payment_method('Klarna US').tap do |payment_method|
          payment_method.click
          yield payment_method.find('input') if block
        end

        wait_until_klarna_credit_visible

        klarna_credit(&:wait_until_klarna_credit_logo_visible)
      end
    end

    def select_credit_card(&block)
      select_payment_method('Credit Card').tap do |payment_method|
        payment_method.click
        yield payment_method.find('input') if block
      end
    end

    def select_check(&block)
      select_payment_method('Check').tap do |payment_method|
        payment_method.click
        yield payment_method.find('input') if block
      end
    end

    def continue(_store_data = nil)
      Capybara.using_wait_time(30) do
        continue_button.click
      end
    end

    def has_coupon_code_field?
      order_coupon_code.set("")
    rescue StandardError
      nil
    end

    def is_coupon_applied?
      summary.text.match(/Promotion/)
    end
  end
end
