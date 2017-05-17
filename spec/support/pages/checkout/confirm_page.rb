module Checkout
  class ConfirmPage < SitePrism::Page
    set_url "/checkout/confirm"

    element :continue_button, ".continue[type='submit']"
  end
end
