module PageDrivers
  class Cart < Base
    def has_item_by_name?(name)
      within '#line_items' do
        @page.has_content?(name)
      end
    end

    def continue
      click_button 'Checkout'
    end
  end
end

