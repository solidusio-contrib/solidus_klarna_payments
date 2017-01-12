module PageDrivers
  class Address < Base
    def set_address(data, address= :billing)
      case address
      when :billing
        within 'fieldset#billing' do
          fill_in 'First Name', with: data[:first_name]
          fill_in 'Last Name', with: data[:last_name]
          fill_in 'Street Address', with: data[:street_address]
          fill_in 'City', with: data[:city]
          select data[:country], from: 'Country'
          fill_in 'Zip', with: data[:zip]
          fill_in 'Phone', with: data[:phone]
          find('#order_bill_address_attributes_state_id').select(data[:state])
        end
      when :shipping
        within 'fieldset#shipping' do
          check 'Use Billing Address'
          fill_in 'First Name', with: data[:first_name]
          fill_in 'Last Name', with: data[:last_name]
          fill_in 'Street Address', with: data[:street_address]
          fill_in 'City', with: data[:city]
          select data[:country], from: 'Country'
          fill_in 'Zip', with: data[:zip]
          fill_in 'Phone', with: data[:phone]
          find('#order_ship_address_attributes_state_id').select(data[:state])
        end
      end
    end

    def continue
      click_button 'Save and Continue'
    end
  end
end

