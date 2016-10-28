module Spree
  class LineItemSerializer
    attr_reader :line_item

    def initialize(line_item)
      @line_item = line_item
    end

    def to_hash
      {
        reference: line_item.sku,
        name: line_item.name,
        quantity: line_item.quantity,
        # unit price with taxes without adjustments
        unit_price: unit_price,
        # tax rate, e.g. 500 for 5.00%
        tax_rate: line_item_tax_rate,
        # total amount including tax and adjustments * quantity
        total_amount: total_amount,
        # absolute tax amount
        total_tax_amount: total_tax_amount
      }
    end

    private

    def line_item_tax_rate
      # TODO: find a better way to calculate this
      (10000 * line_item.adjustments.find_by(source_type: "Spree::TaxRate").source.amount).to_i
    end

    def total_amount
      (line_item.display_price.cents + total_tax_amount) * line_item.quantity
    end

    def total_tax_amount
      line_item.display_additional_tax_total.cents
    end

    def unit_price
      line_item.display_price.cents + line_item.display_additional_tax_total.cents
    end
  end
end
