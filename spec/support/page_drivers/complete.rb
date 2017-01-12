module PageDrivers
  class Complete < Base
    def is_valid?
      expect(page).to have_content('Your order has been processed successfully')
    end

    def get_order_number
      expect(find('fieldset#order_summary h1').text).to match(/Order /)
      find('fieldset#order_summary h1').text.gsub("Order ", "")
    end
  end
end
