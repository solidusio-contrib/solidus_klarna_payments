module PageDrivers
  class Address < Base
    def set_address(data, address= :billing)
      case address
      when :billing
        within 'fieldset#billing' do
          fill_in 'order_bill_address_attributes_firstname', with: data[:first_name]
          fill_in 'order_bill_address_attributes_lastname', with: data[:last_name]
          fill_in 'order_bill_address_attributes_address1', with: data[:street_address]
          fill_in 'order_bill_address_attributes_city', with: data[:city]
          find('#order_bill_address_attributes_country_id').select(data[:country])
          fill_in 'order_bill_address_attributes_zipcode', with: data[:zip]
          fill_in 'order_bill_address_attributes_phone', with: data[:phone]
          find('#order_bill_address_attributes_state_id').select(data[:state])
        end
      when :shipping
        within 'fieldset#shipping' do
          check 'Use Billing Address'
          fill_in 'order_ship_address_attributes_firstname', with: data[:first_name]
          fill_in 'order_ship_address_attributes_lastname', with: data[:last_name]
          fill_in 'order_ship_address_attributes_address1', with: data[:street_address]
          fill_in 'order_ship_address_attributes_city', with: data[:city]
          find('#order_ship_address_attributes_country_id').select(data[:country])
          fill_in 'order_ship_address_attributes_zipcode', with: data[:zip]
          fill_in 'order_ship_address_attributes_phone', with: data[:phone]
          find('#order_ship_address_attributes_state_id').select(data[:state])
        end
      end
    end

    def continue
      within 'form#checkout_form_address' do
        find('input.continue').click
      end
    end
  end
end

