require 'spec_helper'

describe Spree::OrderSerializer do
  context "in the US" do
    let!(:us) { create(:country, name: "USA") }
    let(:us_zone) { create(:global_zone, default_tax: true) }
    let!(:tax_rate) { create(:tax_rate, zone: us_zone) }

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
      shipping_lines = serialized[:order_lines].count { |l| l[:type] == "shipping_fee" }
      expect(shipping_lines).to eq(1)
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
end

