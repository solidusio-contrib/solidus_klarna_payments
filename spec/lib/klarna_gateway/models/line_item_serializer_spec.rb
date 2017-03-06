require 'spec_helper.rb'

describe KlarnaGateway::LineItemSerializer do
  let(:order) { create(:order_with_line_items, line_items_count: 3) }
  let(:serialized) { serializer.to_hash }
  subject(:serializer) { KlarnaGateway::LineItemSerializer.new(line_item, calculator) }
  let(:line_item) { order.line_items.first }

  context "in the UK" do
    let(:calculator) { KlarnaGateway::AmountCalculators::UK::LineItemCalculator.new }
    let(:region) { :us }
    let!(:uk) { create(:country, name: "United Kingdom") }
    let(:uk_zone) { create(:global_zone, default_tax: true) }
    let!(:tax_rate) { create(:tax_rate, zone: uk_zone, included_in_price: true) }

    it "sets the tax amount" do
      expect(serialized[:total_tax_amount]).to be > 0
      expect(serialized[:total_tax_amount]).to eq((line_item.adjustments.tax.first.amount * 100).to_i)
    end

    it "sets the unit_price" do
      expect(serialized[:unit_price]).to be > 0
      expect(serialized[:unit_price]).to eq(line_item.display_price.cents)
    end

    it "sets the total_amount" do
      expect(serialized[:total_amount]).to be > 0
      expect(serialized[:total_amount]).to eq(line_item.display_total.cents)
    end

    it "does not set a discount" do
      expect(serialized[:discount_amount]).to eq(0)
    end

    it "sets the tax_rate" do
      expect(serialized[:tax_rate]).to eq((tax_rate.amount * 10000).to_i)
    end

    it "sets the product url" do
      expect(serialized[:product_url]).to_not eq(nil)
    end
  end
end
