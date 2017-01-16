module PageDrivers
  class Delivery < Base
    def has_item_by_name?(name)
      within '#shipping_method' do
        has_content?(name)
      end
    end

    def continue
      within 'form#checkout_form_delivery' do
        find('input.continue').click
      end
    end
  end
end

