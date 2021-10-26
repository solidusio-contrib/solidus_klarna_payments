# frozen_string_literal: true

module SolidusKlarnaPayments
  class CustomerTokenSerializer
    def initialize(order:, description:, region: :us)
      @order = order
      @description = description
      @region = region.downcase.to_sym
    end

    def to_hash
      return {} unless order

      {
        locale: locale,
        intended_use: 'SUBSCRIPTION',
        description: description,
        purchase_country: purchase_country,
        purchase_currency: order.currency,
        billing_address: billing_address,
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
      order.billing_address.try(:country).try(:iso) ||
        order.shipping_address.try(:country).try(:iso) ||
        region
    end

    def billing_address
      address = order.billing_address.presence || order.shipping_address

      {
        email: order.email
      }.merge(
        AddressSerializer.new(address).to_hash
      )
    end

    attr_reader :order, :description, :region
  end
end
