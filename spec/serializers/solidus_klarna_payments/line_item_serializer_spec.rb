# frozen_string_literal: true

require 'spec_helper.rb'

describe SolidusKlarnaPayments::LineItemSerializer do
  context "in the UK" do
    it "sets the total_tax_amount" do
      create_tax_rate
      line_item = create_line_item

      serialized_hash = build_serializer_for(line_item).to_hash

      expect(serialized_hash[:total_tax_amount]).to be > 0
      expect(serialized_hash[:total_tax_amount]).to eq((line_item.adjustments.tax.first.amount.abs * 100).to_i)
    end

    it "sets the tax_rate" do
      tax_rate = create_tax_rate
      line_item = create_line_item

      serialized_hash = build_serializer_for(line_item).to_hash

      expect(serialized_hash[:tax_rate]).to eq((tax_rate.amount * 10_000).to_i)
    end

    it "sets the unit_price" do
      line_item = create_line_item

      serialized_hash = build_serializer_for(line_item).to_hash

      expect(serialized_hash[:unit_price]).to be > 0
      expect(serialized_hash[:unit_price]).to eq(line_item.single_money.cents)
    end

    it "sets the total_amount" do
      line_item = create_line_item

      serialized_hash = build_serializer_for(line_item).to_hash

      expect(serialized_hash[:total_amount]).to be > 0
      expect(serialized_hash[:total_amount]).to eq(line_item.display_amount.cents)
    end

    it "does not set a discount" do
      line_item = create_line_item

      serialized_hash = build_serializer_for(line_item).to_hash

      expect(serialized_hash[:discount_amount]).to eq(0)
    end

    describe "product_url" do
      around do |example|
        before = SolidusKlarnaPayments.configuration.product_url
        SolidusKlarnaPayments.configuration.product_url = product_url
        example.run
        SolidusKlarnaPayments.configuration.product_url = before
      end

      context "without a URL configured" do
        let(:product_url) { nil }

        it "does not generate a product url" do
          line_item = create_line_item

          serialized_hash = build_serializer_for(line_item).to_hash

          expect(serialized_hash[:product_url]).to eq(nil)
        end
      end

      context "with a Proc configured" do
        let(:product_url) { proc{ |line_item| "http://example.com/product/#{line_item.variant.id}" } }

        it "returns the result as a string" do
          line_item = create_line_item

          serialized_hash = build_serializer_for(line_item).to_hash

          expect(serialized_hash[:product_url]).to be_a(String)
          expect(serialized_hash[:product_url]).to eq("http://example.com/product/#{line_item.variant.id}")
        end
      end

      context "with a String configured" do
        let(:product_url) { "TOO_STATIC" }

        it "falls back to nil" do
          line_item = create_line_item

          serialized_hash = build_serializer_for(line_item).to_hash

          expect(serialized_hash[:product_url]).to eq(nil)
        end
      end
    end

    describe "image_url" do
      around do |example|
        before = SolidusKlarnaPayments.configuration.image_host
        SolidusKlarnaPayments.configuration.image_host = image_host
        example.run
        SolidusKlarnaPayments.configuration.image_host = before
      end

      context "with nil as image_host" do
        let(:image_host) { nil }

        it "falls back to nil" do
          line_item = create_line_item_with_image

          serialized_hash = build_serializer_for(line_item).to_hash

          expect(serialized_hash[:image_url]).to eq(nil)
        end
      end

      context "with a string as image_host" do
        let(:image_host) { "example.com" }

        it "uses the string as host" do
          line_item = create_line_item_with_image

          serialized_hash = build_serializer_for(line_item).to_hash

          expect(serialized_hash[:image_url]).to start_with("http://example.com/")
        end
      end

      context "with a Proc configured" do
        let(:image_host) { proc{ |_line_item| "http://example.com" } }

        it 'calls the proc to get the host' do
          line_item = create_line_item_with_image

          serialized_hash = build_serializer_for(line_item).to_hash

          expect(serialized_hash[:image_url]).to eq("http://example.com#{line_item.variant.images.first.attachment.url}")
        end
      end

      private

      def create_line_item_with_image
        create_line_item.tap do |line_item|
          line_item.variant.images << create(:image)
        end
      end
    end

    private

    def create_tax_rate
      gb_country = create(:country, iso: 'GB')
      gb_zone = create(:zone, countries: [gb_country])

      create(:tax_rate, zone: gb_zone)
    end
  end

  private

  def create_line_item
    create(:order_with_line_items,
      line_items_count: 1,
      ship_address: create(:ship_address, country_iso_code: 'GB'),).line_items.first
  end

  def build_serializer_for(line_item)
    calculator = SolidusKlarnaPayments::AmountCalculators::Uk::LineItemCalculator.new
    SolidusKlarnaPayments::LineItemSerializer.new(line_item, calculator)
  end
end
