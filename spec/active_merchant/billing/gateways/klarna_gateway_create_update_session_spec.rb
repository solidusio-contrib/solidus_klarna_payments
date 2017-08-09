require "spec_helper"

describe ActiveMerchant::Billing::KlarnaGateway do
  include_context "Klarna API helper"
  let(:client){ double("KlarnaClient") }
  let(:order){ {order_id: 1} }

  context "On Creating a Session" do
    it "forwards the request to Klarna SDK" do
      expect(client).to receive(:create_session).with(order).and_return({message: "true"})
      expect(Klarna).to receive(:client).with(:credit).and_return(client)

      payment.payment_method.provider.create_session(order).tap do |response|
        expect(response.has_key?(:message)).to be(true)
        expect(response[:message]).to eq("true")
      end
    end
  end

  context "On updating session" do
    it "forwards the request to Klarna SDK" do
      expect(client).to receive(:update_session).with(1, order).and_return({message: "true"})
      expect(Klarna).to receive(:client).with(:credit).and_return(client)

      payment.payment_method.provider.update_session(1, order).tap do |response|
        expect(response.has_key?(:message)).to be(true)
        expect(response[:message]).to eq("true")
      end
    end
  end
end
