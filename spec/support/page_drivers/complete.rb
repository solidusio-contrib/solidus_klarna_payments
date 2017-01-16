module PageDrivers
  class Complete < Base
    def is_valid?
      if $data.de?
        expect(page).to have_content('Ihre Bestellung wurde erfolgreich bearbeitet')
      else
        expect(page).to have_content('Your order has been processed successfully')
      end
    end

    def get_order_number
      expect(find('fieldset#order_summary h1').text).to match(/Order|Bestellnummer /)
      find('fieldset#order_summary h1').text.gsub("Order|Bestellnummer ", "")
    end
  end
end
