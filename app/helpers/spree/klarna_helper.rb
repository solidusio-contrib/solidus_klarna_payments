# frozen_string_literal: true

module Spree
  module KlarnaHelper
    def cents_to_display_money(cents, currency = nil)
      Spree::Money.new(BigDecimal(cents) / 100, currency: currency).to_html
    end
  end
end
