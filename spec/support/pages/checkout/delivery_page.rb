module Checkout
  class DeliveryPage < SitePrism::Page
    set_url "/checkout/delivery"

    elements :shipping_methods, ".shipping-methods li.shipping-method"

    element :continue_button, ".continue[type='submit']"
  end
end
