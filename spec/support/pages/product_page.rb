class ProductPage < SitePrism::Page
  set_url "/products/{slug}"

  element :cart_button, '#add-to-cart-button'
  element :quantity_field, 'input#quantity' 
end
