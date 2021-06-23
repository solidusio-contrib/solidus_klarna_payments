# frozen_string_literal: true

require "spec_helper"

describe Spree::PaymentMethod::KlarnaCredit do
  describe "capture", :klarna_api do
    let(:order) { create(:order_with_line_items) }
    let(:gateway) { double(:gateway) }
    let(:amount) { 100 }
    let(:klarna_order_id) { "KLARNA_ORDER_ID" }

    # Regression test
    it "does not error" do
      expect(subject).to receive(:gateway).and_return(gateway)
      expect(gateway).to receive(:capture)
      expect {
        subject.capture(amount, klarna_order_id, order_id: "#{order.number}-dummy")
      }.not_to raise_error
    end
  end
end
