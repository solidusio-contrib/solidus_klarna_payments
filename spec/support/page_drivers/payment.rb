module PageDrivers
  class KlarnaCredit < SitePrism::Page
    elements :options, 'label'
  end

  class KlarnaCreditFullscreen < SitePrism::Page
    element :date_field, "#purchaseApproval-dataCollection-dateOfBirth"
    element :agreement_field, "#purchaseApproval-dataCollection-agreeCheckbox"
    element :continue_button, "button#purchaseApproval-continueButton"
  end

  class Payment < SitePrism::Page
    set_url "/checkout/payment"

    elements :payment_methods, "fieldset#payment #payment-method-fields label"
    element :continue_button, "form#checkout_form_payment input.continue"
    element :klarna_error, ".klarna_error"

    iframe :klarna_credit, KlarnaCredit, '#klarna-credit-main'
    iframe :klarna_credit_fullscreen, KlarnaCreditFullscreen, '#klarna-credit-fullscreen'

    def select_payment_method(name)
      payment_methods.find{|e| e.text.match(/#{name}/)}
    end

    def select_klarna
      select_payment_method('Klarna Credit US').click
      wait_for_klarna_credit

      klarna_credit do |frame|
        if $data.us?
          wait_for_klarna_credit
          frame.options.first.click
        end
      end

      wait_for_klarna_credit
    end


    def select_credit_card
      select_payment_method('Credit Card').click
    end


    def select_check
      select_payment_method('Check').click
    end

    def continue
      continue_button.click

      wait_for_klarna_credit

      if $data.de?
        klarna_credit_fullscreen do |frame|
          frame.date_field.set '10.10.1970'
          frame.agreement_field.click
          frame.continue_button.click
        end
        wait_for_klarna_credit_fullscreen
      end
    end
  end
end
