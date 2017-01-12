module PageDrivers
  class Delivery < Base
    def has_item_by_name?(name)
      within '#shipping_method' do
        has_content?(name)
      end
    end

    def continue
      click_button 'Save and Continue'
    end
  end
end

