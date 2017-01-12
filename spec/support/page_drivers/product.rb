module PageDrivers
  class Product < Base
    def has_name?(name)
      within '#product-description' do
        @page.has_css?(:h1, name)
      end
    end

    def add_to_cart(number)
      fill_in :quantity, with: number
      click_button 'Add To Cart'
    end
  end
end

