# frozen_string_literal: true

require 'spec_helper'

describe SolidusKlarnaPayments::OrderSerializer do
  subject(:serializer) { described_class.new(order, region) }

  let(:order) { create(:order_with_line_items, line_items_count: 3) }
  let(:serialized) { serializer.to_hash }
  let(:region) { :us }
  let!(:country) { Spree::Country.find_by(name: "USA") || create(:country, name: "USA") }
  let(:zone) { Spree::Zone.find_by(name: 'GlobalZone') || create(:global_zone) }
  let!(:tax_rate) { create(:tax_rate, zone: zone) }

  let(:overbooked_order) do
    create(:order_with_line_items, line_items_count: 3).tap do |order|
      order.line_items.first.variant.stock_items.first.adjust_count_on_hand 2
      order.line_items.first.update(quantity: 4)
      order.reload.create_proposed_shipments
      order.recalculate
    end.reload
  end

  context "in the US" do
    let(:region) { :us }
    let!(:us) { Spree::Country.find_by(name: "USA") || create(:country, name: "USA") }
    let(:us_zone) { Spree::Zone.find_by(name: 'GlobalZone') || create(:global_zone) }
    let!(:tax_rate) { create(:tax_rate, zone: us_zone) }

    it "sets the amount" do
      expect(serialized[:order_amount]).to eq(order.display_total.cents)
    end

    it "sets the locale" do
      expect(serialized[:locale]).to eq("en-US")
    end

    it "sets the tax amount" do
      expect(serialized[:order_tax_amount]).to eq(order.display_tax_total.cents)
    end

    it "has multiple lines of shipping fees" do
      create(:shipping_method)
      allow_any_instance_of(Spree::Shipment).to receive(:shipping_method).and_return(Spree::ShippingMethod.last)
      serialized = described_class.new(overbooked_order, region).to_hash
      shipping_lines = serialized[:order_lines].count { |l| l[:type] == "shipping_fee" }
      expect(shipping_lines).to eq(overbooked_order.shipments.count)
    end

    it "has one line for sales tax" do
      create(:tax_category)
      create(:tax_rate, tax_categories: [Spree::TaxCategory.last])
      tax_lines = serialized[:order_lines].count { |l| l[:type] == "sales_tax" }
      expect(tax_lines).to eq(1)
    end

    it "sets the tax line's amount correctly" do
      tax_line = serialized[:order_lines].detect { |l| l[:type] == "sales_tax" }
      expect(tax_line[:quantity]).to eq(1)
      expect(tax_line[:unit_price]).to eq(order.display_tax_total.cents)
      expect(tax_line[:total_amount]).to eq(order.display_tax_total.cents)
      expect(tax_line[:tax_rate]).to eq(0)
      expect(tax_line[:total_tax_amount]).to eq(0)
    end

    it "doesn't have a discount line" do
      discount_lines = serialized[:order_lines].count { |l| l[:type] == "discount" }
      expect(discount_lines).to eq(0)
    end

    context "with configured merchant url" do
      before do
        allow_any_instance_of(SolidusKlarnaPayments::Configuration).to receive(:confirmation_url)
          .and_return(->(_store, _order) { "my_confirmation_url" })
      end

      xit "is present in the output" do
        expect(serialized[:merchant_urls][:confirmation]).to eq("my_confirmation_url")
      end
    end

    it 'has the correct keys' do
      expect(serialized.keys).to eq(
        [
          :purchase_country,
          :purchase_currency,
          :locale,
          :order_amount,
          :shipping_address,
          :order_lines,
          :merchant_reference1,
          :options,
          :order_tax_amount
        ]
      )
    end
  end

  context "in the UK with included tax" do
    let(:region) { :uk }
    let!(:country) { create(:country) }
    let!(:tax_rate) { create(:tax_rate, zone: zone, included_in_price: true) }
    let!(:uk) { Spree::Country.find_by(name: "United Kingdom") || create(:country, name: "United Kingdom") }
    let(:uk_zone) { Spree::Zone.find_by(name: 'GlobalZone') || create(:global_zone) }
    let!(:tax_rate) { create(:tax_rate, zone: uk_zone, included_in_price: true) }

    it "sets the amount" do
      expect(serialized[:order_amount]).to eq(order.display_total.cents)
    end

    it "sets the locale" do
      expect(serialized[:locale]).to eq("en-GB")
    end

    describe "the tax details" do
      it "sets the tax amount" do
        expect(serialized).not_to have_key(:order_tax_amount)
      end

      it "has no separate tax line" do
        tax_lines = serialized[:order_lines].count { |l| l[:type] == "sales_tax" }
        expect(tax_lines).to eq(0)
      end
    end

    describe "the shipping" do
      let(:shipping_line) do
        serialized[:order_lines].detect { |l| l[:type] == "shipping_fee" }
      end

      it "has one line" do
        shipping_lines = serialized[:order_lines].count { |l| l[:type] == "shipping_fee" }
        expect(shipping_lines).to eq(1)
      end

      it "has the correct amounts" do
        expect(shipping_line[:quantity]).to eq(1)
        order.reload.shipments.first
        expect(shipping_line[:tax_rate]).to eq(0)
      end
    end

    describe "the discount" do
      it "is not in the order_lines" do
        discount_lines = serialized[:order_lines].count { |l| l[:type] == "discount" }
        expect(discount_lines).to eq(0)
      end
    end

    context "without personal data" do
      before do
        serializer.skip_personal_data = true
      end

      it "excludes the address attributes" do
        expect(serialized).not_to include(:billing_address, :shipping_address)
      end
    end

    it 'has the correct keys' do
      expect(serialized.keys).to eq(
        [
          :purchase_country,
          :purchase_currency,
          :locale,
          :order_amount,
          :shipping_address,
          :order_lines,
          :merchant_reference1,
          :options
        ]
      )
    end
  end

  context "in Germany" do
    let(:region) { :de }
    let!(:tax_rate) { create(:tax_rate, zone: zone, included_in_price: true) }
    let!(:germany) { Spree::Country.find_by(name: "Deutschland") || create(:country, name: "Deutschland", iso: "de") }
    let(:de_zone) { Spree::Zone.find_by(name: 'GlobalZone') || create(:global_zone) }
    let!(:tax_rate) { create(:tax_rate, zone: de_zone, included_in_price: true) }

    it "sets the locale" do
      expect(serialized[:locale]).to eq("de-DE")
    end

    it 'has the correct keys' do
      expect(serialized.keys).to eq(
        [
          :purchase_country,
          :purchase_currency,
          :locale,
          :order_amount,
          :shipping_address,
          :order_lines,
          :merchant_reference1,
          :options
        ]
      )
    end

    context "without personal data" do
      before do
        serializer.skip_personal_data = true
      end

      it "excludes the address attributes" do
        expect(serialized).not_to include(:billing_address, :shipping_address)
      end
    end
  end

  context "in Austria" do
    let(:region) { :at }
    let!(:tax_rate) { create(:tax_rate, zone: zone, included_in_price: true) }

    it "sets the locale" do
      expect(serialized[:locale]).to eq("de-AT")
    end

    it 'has the correct keys' do
      expect(serialized.keys).to eq(
        [
          :purchase_country,
          :purchase_currency,
          :locale,
          :order_amount,
          :shipping_address,
          :order_lines,
          :merchant_reference1,
          :options
        ]
      )
    end
  end

  context "in Sweden" do
    let(:region) { :se }
    let!(:tax_rate) { create(:tax_rate, zone: zone, included_in_price: true) }

    it "sets the locale" do
      expect(serialized[:locale]).to eq("sv-SE")
    end

    it 'has the correct keys' do
      expect(serialized.keys).to eq(
        [
          :purchase_country,
          :purchase_currency,
          :locale,
          :order_amount,
          :shipping_address,
          :order_lines,
          :merchant_reference1,
          :options
        ]
      )
    end
  end
end
