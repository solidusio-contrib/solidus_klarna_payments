class CartPage < SitePrism::Page
  set_url "/cart"

  elements :line_items, "#line_items tr.line-item"

  element :checkout_button, "#checkout-link"
  element :update_button, "#update-button"
  element :coupon_field, "input#order_coupon_code"
  element :clear_cart_button, "form#empty-cart input[type='submit']"
end
