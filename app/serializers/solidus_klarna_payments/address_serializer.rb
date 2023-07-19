# frozen_string_literal: true

module SolidusKlarnaPayments
  class AddressSerializer
    attr_reader :address

    def initialize(the_address = nil)
      @address = the_address
    end

    def to_hash
      return {} if address.nil?

      {
        organization_name: address.company,
        given_name: given_name(address),
        family_name: family_name(address),
        street_address: address.address1,
        street_address2: address.address2,
        postal_code: address.zipcode,
        city: address.city,
        region: region,
        phone: address.phone.to_s.gsub(/^\+1/, ""),
        country: address.country.iso
      }
    end

    protected

    def region
      if address.country.iso == "US"
        address.state.try(:abbr)
      else
        address.state.try(:name)
      end
    end

    def given_name(address)
      return address.first_name unless SolidusSupport.combined_first_and_last_name_in_address?

      address.name.split("\s", 2)[0]
    end

    def family_name(address)
      return address.last_name unless SolidusSupport.combined_first_and_last_name_in_address?

      address.name.split("\s", 2)[1]
    end
  end
end
