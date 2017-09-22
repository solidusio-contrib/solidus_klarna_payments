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
    let(:uk_zone) { Spree::Zone.find_by_name('GlobalZone') || create(:global_zone, default_tax: true) }
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

    describe "product url" do
      around do |example|
        before = KlarnaGateway.configuration.product_url
        KlarnaGateway.configuration.product_url = product_url
        example.run
        KlarnaGateway.configuration.product_url = before
      end

      context "without a URL configured" do
        let(:product_url) { nil }

        it "does not generate a product url" do
          expect(serialized[:product_url]).to eq(nil)
        end
      end

      context "with a Prodc configured" do
        let(:product_url) { Proc.new{|line_item| "http://example.com/product/#{line_item.variant.id}"} }

        it "returns the result as a string" do
          expect(serialized[:product_url]).to be_a(String)
          expect(serialized[:product_url]).to eq("http://example.com/product/#{line_item.variant.id}")
        end
      end

      context "with a String configured" do
        let(:product_url) { "TOO_STATIC" }

        it "falls back to nil" do
          expect(serialized[:product_url]).to eq(nil)
        end
      end
    end

    describe "image_url" do
      around do |example|
        before = KlarnaGateway.configuration.product_url
        KlarnaGateway.configuration.image_host = image_host
        example.run
        KlarnaGateway.configuration.image_host = before
      end
      before do
        line_item.variant.images << create(:image)
      end
      subject { serialized[:image_url] }

      context "with nil as image_host" do
        let (:image_host) { nil }
        it { is_expected.to be_nil }
      end

      context "with a string as image_host" do
        let(:image_host) { "example.com" }
        it { is_expected.to start_with("http://example.com/") }
      end
    end
  end
end
