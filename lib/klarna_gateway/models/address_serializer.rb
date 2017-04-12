module KlarnaGateway
  class AddressSerializer
    attr_reader :address

    def initialize(the_address = nil)
      @address = the_address
    end

    def to_hash
      return {} if address.nil?
      {
        organization_name: address.company,
        given_name: address.first_name,
        family_name: address.last_name,
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
  end
end
