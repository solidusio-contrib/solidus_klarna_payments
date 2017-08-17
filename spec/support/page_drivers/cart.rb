module PageDrivers
  class Cart < SitePrism::Page
    set_url "/cart"

    element :line_items, "#line_items"
    element :continue_button, "button#checkout-link"

    def continue
      continue_button.click
    end
  end
end

