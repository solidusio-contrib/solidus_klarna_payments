# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveMerchant::Billing::KlarnaGateway, :klarna_api do
  # authorize(amount, payment_source, options={})
  context "On authorize" do
    before do
      expect(::SolidusKlarnaPayments::OrderSerializer).to receive(:new).once.and_return({})
    end

    it "update payment status to AUTHORIZED when order is authorized" do
      allow(api_client).to receive(:place_order).with(any_args).and_return(klarna_authorize_response)
      allow(api_client).to receive(:get).with(any_args).and_return(klarna_order_response)
      expect(Klarna).to receive(:client).twice.with(any_args).and_return(api_client)

      payment.payment_method.gateway.authorize(10, payment.source, options).tap do |response|
        expect(response).to be_a(ActiveMerchant::Billing::Response)
        expect(payment.source).to be_accepted
        expect(payment.source).to be_authorized
        expect(payment.source).not_to be_expired
      end
    end

    it "updates the payment status to ERROR when order had an error" do
      allow(api_client).to receive(:place_order).with(any_args).and_return(klarna_negative_response)
      expect(api_client).not_to receive(:get).with(any_args)
      expect(Klarna).to receive(:client).once.with(any_args).and_return(api_client)

      payment.payment_method.gateway.authorize(10, payment.source, options).tap do |response|
        expect(response).to be_a(ActiveMerchant::Billing::Response)
        expect(payment.source).to be_error
        expect(payment.source).not_to be_authorized
        expect(payment.source).not_to be_expired
      end
    end
  end

  # cancel(order_id)
  context "On cancel" do
    it "update payment status to CANCELLED" do
      allow(api_client).to receive(:cancel).with(any_args).and_return(klarna_empty_success_response)
      allow(api_client).to receive(:get).with(any_args).and_return(klarna_cancelled_response)
      allow(Klarna).to receive(:client).with(any_args).and_return(api_client)

      payment.payment_method.gateway.cancel(payment.source.order_id).tap do |response|
        expect(response).to be_a(ActiveMerchant::Billing::Response)
        payment.source.reload
        expect(payment.source).to be_cancelled
        expect(payment.source).not_to be_authorized
      end
    end
  end

  # capture(amount, order_id, options={})
  context "On capture" do
    it "update payment status to CAPTURED" do
      allow(api_client).to receive(:capture).with(any_args).and_return(klarna_empty_success_response)
      allow(api_client).to receive(:get).with(any_args).and_return(klarna_captured_response)
      allow(Klarna).to receive(:client).with(any_args).and_return(api_client)

      payment.payment_method.gateway.capture(10, payment.source.order_id, options).tap do |response|
        expect(response).to be_a(ActiveMerchant::Billing::Response)
        payment.source.reload
        expect(payment.source).to be_captured
        expect(payment.source).not_to be_authorized
      end
    end
  end

  # purchase(amount, payment_source, options={})
  context "On purchase" do
    it "calls to authorize and capture" do
      expect(payment.payment_method.gateway).to receive(:authorize).and_return(double('Response', success?: true))
      expect(payment.payment_method.gateway).to receive(:capture).and_return({})
      payment.payment_method.gateway.purchase(10, payment.source, options).tap do |response|
        expect(response).to eq(response)
      end
    end
  end

  # refund(amount, order_id, options={})
  context "On refund" do
    it "update payment status to CAPTURED" do
      allow(api_client).to receive(:create).with(any_args).and_return(klarna_empty_success_response)
      allow(api_client).to receive(:get).with(any_args).and_return(klarna_captured_response)
      expect(Klarna).to receive(:client).twice.with(any_args).and_return(api_client)
      expect(payment.source).not_to be_captured

      payment.payment_method.gateway.refund(10, payment.source.order_id, options).tap do |response|
        expect(response).to be_a(ActiveMerchant::Billing::Response)
        payment.source.reload
        expect(payment.source).to be_captured
        expect(payment.source).not_to be_authorized
      end
    end
  end

  context "With missing configuration" do
    it "raises an error" do
      expect {
        described_class.new({})
      }.to raise_error(::SolidusKlarnaPayments::InvalidConfiguration)
    end
  end

  context "On Creating a Session" do
    include_context "Klarna API helper"
    let(:client){ double("KlarnaClient") }
    let(:order){ { order_id: 1 } }

    it "forwards the request to Klarna SDK" do
      expect(client).to receive(:create_session).with(order).and_return(message: "true")
      expect(Klarna).to receive(:client).with(:credit).and_return(client)

      payment.payment_method.gateway.create_session(order).tap do |response|
        expect(response.key?(:message)).to be(true)
        expect(response[:message]).to eq("true")
      end
    end
  end

  context "On updating session" do
    include_context "Klarna API helper"
    let(:client){ double("KlarnaClient") }
    let(:order){ { order_id: 1 } }

    it "forwards the request to Klarna SDK" do
      expect(client).to receive(:update_session).with(1, order).and_return(message: "true")
      expect(Klarna).to receive(:client).with(:credit).and_return(client)

      payment.payment_method.gateway.update_session(1, order).tap do |response|
        expect(response.key?(:message)).to be(true)
        expect(response[:message]).to eq("true")
      end
    end
  end
end
