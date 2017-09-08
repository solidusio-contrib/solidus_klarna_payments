module Checkout
  class RegistrationPage < SitePrism::Page
    set_url "/checkout/registration"

    element :customer_email_field, "#order_email"
    element :continue_button, "input[value='Continue'][type='submit']"
  end
end
