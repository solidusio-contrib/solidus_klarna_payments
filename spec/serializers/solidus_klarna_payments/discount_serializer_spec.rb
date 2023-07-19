# frozen_string_literal: true

require 'spec_helper'

describe SolidusKlarnaPayments::DiscountItemSerializer do
  subject(:serializer) { SolidusKlarnaPayments::OrderSerializer.new(order) }

  let(:order) { create(:completed_klarna_order_with_promotion, promotion: promotion) }
  let(:serialized) { serializer.to_hash }

  before do
    order.recalculate
    allow_any_instance_of(Spree::Shipment).to receive(:shipping_method).and_return(Spree::ShippingMethod.last)
  end

  context "on the whole order" do
    let(:promotion) { create(:promotion, :with_order_adjustment, code: "MYCODE") }

    it "sets correct discount amounts" do
      discount_line = serialized[:order_lines].detect { |l| l[:type] == "discount" }
      expect(discount_line[:quantity]).to eq(1)
      expect(discount_line[:reference]).to eq("MYCODE".downcase)
      expect(discount_line[:total_amount]).to eq((order.promo_total * 100).to_i)
      expect(discount_line[:tax_rate]).to eq(0)
    end
  end

  context "on lines items" do
    let(:promotion) { create(:promotion_with_item_adjustment, code: "MYCODE") }

    it "has one discount line" do
      discount_lines = serialized[:order_lines].select { |l| l[:type] == "discount" }
      expect(discount_lines.count).to eq(1)
      expect(discount_lines.first[:name]).to match("Promo")
    end

    it "does not set line items' discount value" do
      line_items_with_discount = serialized[:order_lines].count do |line|
        line[:type] == "line_item" && !line[:total_discount_amount].nil?
      end
      expect(line_items_with_discount).to eq(0)
    end

    it "sets correct discount amounts" do
      discount_line = serialized[:order_lines].detect { |l| l[:type] == "discount" }
      expect(discount_line[:quantity]).to eq(1)
      expect(discount_line[:reference]).to eq("MYCODE".downcase)
      expect(discount_line[:total_amount]).to eq((order.promo_total * 100).to_i)
      expect(discount_line[:total_amount]).to be < 0
      expect(discount_line[:tax_rate]).to eq(0)
    end
  end
end
