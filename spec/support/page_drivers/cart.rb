module PageDrivers
  class Cart < Base
    set_url "/cart"

    element :line_items, "#line_items"
    element :continue_button, "button#checkout-link"
    element :coupon_field, "input#order_coupon_code"
    element :update_button, "#update-button"
    element :adjustment, "#cart_adjustments"

    def continue
      continue_button.click
    end

    def add_coupon_code(code)
      coupon_field.set(code)
      update_button.click
    end

    def has_coupon_field?
      coupon_field.set("") rescue nil
    end
  end
end
