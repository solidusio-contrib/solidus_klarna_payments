require 'spec_helper'

describe Spree::OrderSerializer do
  let(:order) { create(:order_with_line_items, line_items_count: 3) }
  let(:overbooked_order) do
    create(:order_with_line_items, line_items_count: 3).tap do |order|
      order.line_items.first.variant.stock_items.first.adjust_count_on_hand 2
      order.line_items.first.update_attributes(quantity: 4)
      order.reload.create_proposed_shipments
      Spree::OrderUpdater.new(order).update
    end.reload
  end
  subject(:serializer) { Spree::OrderSerializer.new(order, region) }
  let(:serialized) { serializer.to_hash }

  context "in the US" do
    let(:region) { :us }
    let!(:us) { create(:country, name: "USA") }
    let(:us_zone) { create(:global_zone, default_tax: true) }
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
      serialized = Spree::OrderSerializer.new(overbooked_order, region).to_hash
      shipping_lines = serialized[:order_lines].count { |l| l[:type] == "shipping_fee" }
      expect(shipping_lines).to eq(overbooked_order.shipments.count)
    end

    it "has one line for sales tax" do
      create(:tax_category)
      create(:tax_rate, tax_category: Spree::TaxCategory.last)
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

    it "it doesn't have a discount line" do
      discount_lines = serialized[:order_lines].count { |l| l[:type] == "discount" }
      expect(discount_lines).to eq(0)
    end

    context "with discounts" do
      let(:order) { create(:completed_order_with_promotion, promotion: promotion) }
      before do
        order.update_totals
        order.persist_totals
      end


      context "on the whole order" do
        let(:promotion) { create(:promotion_with_order_adjustment) }

        it "has one discount line" do
          discount_lines = serialized[:order_lines].count { |l| l[:type] == "discount" }
          expect(discount_lines).to eq(1)
        end

        it "sets correct discount amounts" do
          discount_line = serialized[:order_lines].detect { |l| l[:type] == "discount" }
          expect(discount_line[:quantity]).to eq(1)
          expect(discount_line[:reference]).to eq("Discount")
          expect(discount_line[:total_amount]).to eq((order.promo_total * 100).to_i)
          expect(discount_line[:tax_rate]).to eq(0)
        end
      end

      context "on lines items" do
        let(:promotion) { create(:promotion_with_item_adjustment) }

        it "has one discount line" do
          discount_lines = serialized[:order_lines].count { |l| l[:type] == "discount" }
          expect(discount_lines).to eq(1)
        end

        it "does not set line items' discount value" do
          line_items_with_discount = serialized[:order_lines].count do |line|
            line[:type] == "line_item" && line[:total_discount_amount] != nil
          end
          expect(line_items_with_discount).to eq(0)
        end

        it "sets correct discount amounts" do
          discount_line = serialized[:order_lines].detect { |l| l[:type] == "discount" }
          expect(discount_line[:quantity]).to eq(1)
          expect(discount_line[:reference]).to eq("Discount")
          expect(discount_line[:total_amount]).to eq((order.promo_total * 100).to_i)
          expect(discount_line[:total_amount]).to be < 0
          expect(discount_line[:tax_rate]).to eq(0)
        end
      end
    end
  end

  context "in the UK with included tax" do
    let(:region) { :uk }
    let!(:uk) { create(:country, name: "United Kingdom") }
    let(:uk_zone) { create(:global_zone, default_tax: true) }
    let!(:tax_rate) { create(:tax_rate, zone: uk_zone, included_in_price: true) }

    it "sets the amount" do
      expect(serialized[:order_amount]).to eq(order.display_total.cents)
    end

    it "sets the locale" do
      expect(serialized[:locale]).to eq("en-GB")
    end

    describe "the tax details" do
      it "sets the tax amount" do
        expect(serialized).to_not have_key(:order_tax_amount)
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
        shipment = order.reload.shipments.first
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
        expect(serialized).to_not include(:billing_address, :shipping_address)
      end
    end
  end

  context "in Germany" do
    let(:region) { :de }
    let!(:germany) { create(:country, name: "Deutschland", iso: "de") }
    let(:de_zone) { create(:global_zone, default_tax: true) }
    let!(:tax_rate) { create(:tax_rate, zone: de_zone, included_in_price: true) }

    it "sets the locale" do
      expect(serialized[:locale]).to eq("de-DE")
    end

    context "without personal data" do
      before do
        serializer.skip_personal_data = true
      end

      it "excludes the address attributes" do
        expect(serialized).to_not include(:billing_address, :shipping_address)
      end
    end
  end
end

