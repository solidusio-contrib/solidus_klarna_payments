module PageDrivers
  class Product < Base
    def has_name?(name)
      within '#product-description' do
        @page.has_css?(:h1, name)
      end
    end

    def add_to_cart(number)
      fill_in :quantity, with: number
      within '[data-hook="product_price"]' do
        find('button#add-to-cart-button').click
      end
    end
  end
end

