module PageDrivers
  class BillingForm < SitePrism::Section
    element :first_name, 'input#order_bill_address_attributes_firstname'
    element :last_name, 'input#order_bill_address_attributes_lastname'
    element :address, 'input#order_bill_address_attributes_address1'
    element :city, 'input#order_bill_address_attributes_city'
    element :zipcode, 'input#order_bill_address_attributes_zipcode'
    element :phone, 'input#order_bill_address_attributes_phone'
    element :country, '#order_bill_address_attributes_country_id'
    element :state, '#order_bill_address_attributes_state_id'
  end

  class ShippingForm < SitePrism::Section
    element :first_name, 'input#order_ship_address_attributes_firstname'
    element :last_name, 'input#order_ship_address_attributes_lastname'
    element :address, 'input#order_ship_address_attributes_address1'
    element :city, 'input#order_ship_address_attributes_city'
    element :zipcode, 'input#order_ship_address_attributes_zipcode'
    element :phone, 'input#order_ship_address_attributes_phone'
    element :country, '#order_ship_address_attributes_country_id'
    element :state, '#order_ship_address_attributes_state_id'
  end

  class Address < SitePrism::Page
    set_url "/checkout"

    element :continue_button, 'form#checkout_form_address input.continue'

    section :billing_fields, BillingForm, 'fieldset#billing'
    section :shipping_fields, ShippingForm, 'fieldset#shipping'

    def set_address(data, address= :billing)
      case address
      when :billing
        billing_fields.first_name.set(data[:first_name])
        billing_fields.last_name.set(data[:last_name])
        billing_fields.address.set(data[:street_address])
        billing_fields.city.set(data[:city])
        billing_fields.zipcode.set(data[:zip])
        billing_fields.phone.set(data[:phone])
        billing_fields.country.select(data[:country])
        billing_fields.state.select(data[:state])
      when :shipping
        shipping_fields.first_name.set(data[:first_name])
        shipping_fields.last_name.set(data[:last_name])
        shipping_fields.address.set(data[:street_address])
        shipping_fields.city.set(data[:city])
        shipping_fields.zipcode.set(data[:zip])
        shipping_fields.phone.set(data[:phone])
        shipping_fields.country.select(data[:country])
        shipping_fields.state.select(data[:state])
      end
    end

    def continue
      continue_button.click
    end
  end
end

