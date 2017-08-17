module PageDrivers
  class Product < SitePrism::Page
    set_url "/products/{slug}"

    element :title, "h1.product-title"
    element :quantity, "input#quantity"
    element :add_to_cart_button, "button#add-to-cart-button"

    def add_to_cart(number)
      quantity.set number
      add_to_cart_button.click
    end
  end
end

