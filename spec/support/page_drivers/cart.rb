module PageDrivers
  class Cart < Base
    def has_item_by_name?(name)
      within '#line_items' do
        @page.has_content?(name)
      end
    end

    def continue
      within '[data-hook="inside_cart_form"]' do
        find('button#checkout-link').click
      end
    end
  end
end

