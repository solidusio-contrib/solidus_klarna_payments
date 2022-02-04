# frozen_string_literal: true

module SolidusKlarnaPayments
  class CustomerTokenSerializer
    def initialize(email:, address:, currency:, description:, region: :us)
      @email = email
      @address = address
      @description = description
      @currency = currency
      @region = region.downcase.to_sym
    end

    def to_hash
      {
        locale: locale,
        intended_use: 'SUBSCRIPTION',
        description: description,
        purchase_country: purchase_country,
        purchase_currency: currency,
        billing_address: address,
      }
    end

    private

    def locale
      case region
      when :us then 'en-US'
      when :de then 'de-DE'
      when :se then 'sv-SE'
      when :at then 'de-AT'
      when :nl then 'nl-NL'
      when :dk then 'da-DK'
      when :no then 'nb-NO'
      when :fi then 'fi-FI'
      else 'en-GB'
      end
    end

    def purchase_country
      address.try(:country).try(:iso) || region
    end

    def billing_address
      {
        email: order.email
      }.merge(
        AddressSerializer.new(address).to_hash
      )
    end

    attr_reader :email, :address, :description, :currency, :region
  end
end
