module Spree
  class AddressSerializer
    attr_reader :order

    def initialize(address)
      @address = address
    end

    def to_hash
      {
        organization_name: @address.company,
        given_name: @address.first_name,
        family_name: @address.last_name,
        street_address: @address.address1,
        street_address2: @address.address2,
        postal_code: @address.zipcode,
        city: @address.city,
        region: @address.state_name,
        phone: @address.phone,
        country: @address.country.iso
      }
    end
  end
end
