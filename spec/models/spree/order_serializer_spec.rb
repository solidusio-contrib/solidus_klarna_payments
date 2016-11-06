require 'spec_helper'

describe Spree::OrderSerializer do
  context "in the US" do
    let(:order) { create(:order_with_line_items, line_items_count: 3) }
    subject(:serializer) { Spree::OrderSerializer.new(order) }
    let(:serialized) { serializer.to_hash }

    it "sets the amount" do
      expect(serialized[:order_amount]).to eq(order.display_total.cents)
    end

    it "sets the tax amount" do
      expect(serialized[:order_tax_amount]).to eq(order.display_tax_total.cents)
    end

    it "has one line for shipping" do
      shipping_lines = serialized[:order_lines].select { |l| l[:type] == "shipping_fee" }
      expect(shipping_lines.count).to eq(1)
    end

    it "has one line for sales tax" do
      tax_lines = serialized[:order_lines].select { |l| l[:type] == "sales_tax" }
      expect(tax_lines.count).to eq(1)
    end

    it "sets the tax line's amount correctly" do
      tax_line = serialized[:order_lines].detect { |l| l[:type] == "sales_tax" }
      expect(tax_line[:quantity]).to eq(1)
      expect(tax_line[:unit_price]).to eq(order.display_tax_total.cents)
      expect(tax_line[:total_amount]).to eq(order.display_tax_total.cents)
      expect(tax_line[:tax_rate]).to eq(0)
      expect(tax_line[:total_tax_amount]).to eq(0)
    end
  end
end

