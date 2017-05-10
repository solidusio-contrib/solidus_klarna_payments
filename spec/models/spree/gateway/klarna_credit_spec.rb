require "spec_helper"

describe Spree::Gateway::KlarnaCredit do
  describe "capture", :klarna_api do
    let(:order) { create(:order_with_line_items) }
    let(:provider) { double(:provider) }
    let(:amount) { 100 }
    let(:klarna_order_id) { "KLARNA_ORDER_ID" }

    # Regression test
    it "does not error" do
      expect(subject).to receive(:provider).and_return(provider)
      expect(provider).to receive(:capture)
      expect {
        subject.capture(amount, klarna_order_id, {order_id: "#{order.number}-dummy"}) 
      }.to_not raise_error
    end
  end
end
