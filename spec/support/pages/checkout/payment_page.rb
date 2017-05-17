module Checkout
  class KlarnaPayment < SitePrism::Page
    set_url_matcher /klarna\.com/ 

    elements :payment_options, "#combined-account-variants__row label"

    element :payment_selector, "#payment-selector"
  end

  class PaymentPage < SitePrism::Page
    set_url "/checkout/payment"

    elements :payment_methods, "#payment-method-fields input[type='radio']"

    iframe :klarna_payment, Checkout::KlarnaPayment, "#klarna-credit-main"

    element :continue_button, ".continue[type='submit']"
  end
end
