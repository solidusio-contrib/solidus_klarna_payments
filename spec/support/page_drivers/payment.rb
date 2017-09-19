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

  class Payment < SitePrism::Page
    set_url "/checkout/payment"

    elements :payment_methods, "fieldset#payment #payment-method-fields label"
    element :continue_button, "form#checkout_form_payment input.continue"
    element :klarna_error, ".klarna_error"
    element :klarna_credit_logo, "#klarna-logo"

    iframe :klarna_credit, KlarnaCredit, '#klarna-credit-main'
    iframe :klarna_credit_fullscreen, KlarnaCreditFullscreen, '#klarna-credit-fullscreen'

    def select_payment_method(name)
      payment_methods.find{|e| e.text == name }
    end

    def select_klarna(store_data, &block)
      Capybara.using_wait_time(CapybaraExtraWaitTime) do
        select_payment_method(store_data.payment_name).tap do |payment_method|
          payment_method.click
          yield payment_method.find('input') if block
        end

        wait_for_klarna_credit

        klarna_credit do |frame|
          frame.wait_for_klarna_credit_logo

          if store_data.payment_name.include? "US"
            wait_for_klarna_credit
            frame.options.first.click
          end
        end
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

    def continue(store_data=nil)
      Capybara.using_wait_time(CapybaraExtraWaitTime) do
        continue_button.click

        if store_data
          wait_for_klarna_credit_fullscreen
          if store_data.payment_name.include? "DE"
            klarna_credit_fullscreen do |frame|
              frame.date_field.set store_data.address.date
              frame.agreement_field.click
              frame.continue_button.click
            end
            wait_for_klarna_credit_fullscreen
          end
        end
      end
    end
  end
end
