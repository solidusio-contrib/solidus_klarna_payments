module PageDrivers
  class CheckoutSteps < SitePrism::Section
    element :address, :xpath, 'li[1]'
    element :delivery, :xpath, 'li[2]'
    element :payment, :xpath, 'li[3]'
  end

  class Confirm < SitePrism::Page
    set_url "/checkout/confirm"

    section :checkout_steps, CheckoutSteps, 'ol#checkout-step-confirm'
    element :continue_button, "form#checkout_form_confirm input.continue"

    def change_payment
      checkout_steps.payment.click
    end

    def continue
      continue_button.click
    end
  end
end
