module Checkout
  class AddressSection < SitePrism::Section
    element :firstname_field, "[name*='[firstname]']"
    element :lastname_field, "[name*='[lastname]']"
    element :address_field, "[name*='[address1]']"
    element :city_field, "[name*='[city]']"
    element :country_select, "[name*='[country_id]']"
    element :state_select, "[name*='[state_id]']"
    element :zip_field, "[name*='[zipcode]']"
    element :phone_field, "[name*='[phone]']"
    element :use_billing_field, "#order_use_billing"

    def set(address)
      firstname_field.set address.first_name
      lastname_field.set address.last_name
      address_field.set address.address1
      city_field.set address.city
      country_select.select address.country.name
      if has_state_select?
        state_select.select address.state.name
      end
      zip_field.set address.zipcode
      phone_field.set address.phone
    end

    def using_billing_address?
      use_billing_field.checked?
    end
  end

  class AddressPage < SitePrism::Page
    set_url "/checkout/address"

    section :billing_address, Checkout::AddressSection, "#billing"
    section :shipping_address, Checkout::AddressSection, "#shipping"

    elements :errors, ".errors"

    element :error, "#errorExplanation"
    element :customer_email, "#order_email"
    element :continue_button, ".continue[type='submit']"
  end
end
