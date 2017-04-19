require "spec_helper"

module ActiveMerchant
  module Billing
    describe KlarnaGateway, :klarna_api do
      # authorize(amount, payment_source, options={})
      context "On authorize" do
        before :each do
          expect(::KlarnaGateway::OrderSerializer).to receive(:new).once.and_return({})
        end

        it "update payment status to AUTHORIZED when order is authorized" do
          allow(api_client).to receive(:place_order).with(any_args).and_return(klarna_authorize_response)
          allow(api_client).to receive(:get).with(any_args).and_return(klarna_order_response)
          expect(Klarna).to receive(:client).twice.with(any_args).and_return(api_client)

          payment.payment_method.provider.authorize(10, payment.source, options).tap do |response|
            expect(response).to be_a(ActiveMerchant::Billing::Response)
            expect(payment.source).to be_accepted
            expect(payment.source).to be_authorized
            expect(payment.source).to_not be_expired
          end
        end

        it "updates the payment status to ERROR when order had an error" do
          allow(api_client).to receive(:place_order).with(any_args).and_return(klarna_negative_response)
          expect(api_client).to_not receive(:get).with(any_args)
          expect(Klarna).to receive(:client).once.with(any_args).and_return(api_client)

          payment.payment_method.provider.authorize(10, payment.source, options).tap do |response|
            expect(response).to be_a(ActiveMerchant::Billing::Response)
            expect(payment.source).to be_error
            expect(payment.source).to_not be_authorized
            expect(payment.source).to_not be_expired
          end
        end
      end

      # cancel(order_id)
      context "On cancel" do
        it "update payment status to CANCELLED" do
          allow(api_client).to receive(:cancel).with(any_args).and_return(klarna_empty_success_response)
          allow(api_client).to receive(:get).with(any_args).and_return(klarna_cancelled_response)
          expect(Klarna).to receive(:client).twice.with(any_args).and_return(api_client)

          payment.payment_method.provider.cancel(payment.source.order_id).tap do |response|
            expect(response).to be_a(ActiveMerchant::Billing::Response)
            payment.source.reload
            expect(payment.source).to be_cancelled
            expect(payment.source).to_not be_authorized
          end
        end
      end

      # capture(amount, order_id, options={})
      context "On capture" do
        it "update payment status to CAPTURED" do
          allow(api_client).to receive(:capture).with(any_args).and_return(klarna_empty_success_response)
          allow(api_client).to receive(:get).with(any_args).and_return(klarna_captured_response)
          expect(Klarna).to receive(:client).twice.with(any_args).and_return(api_client)

          payment.payment_method.provider.capture(10, payment.source.order_id, options).tap do |response|
            expect(response).to be_a(ActiveMerchant::Billing::Response)
            payment.source.reload
            expect(payment.source).to be_captured
            expect(payment.source).to_not be_authorized
          end
        end
      end

      # purchase(amount, payment_source, options={})
      context "On purchase" do
        it "calls to authorize and capture" do
          expect(payment.payment_method.provider).to receive(:authorize).and_return(double('Response', success?: true))
          expect(payment.payment_method.provider).to receive(:capture).and_return({})
          payment.payment_method.provider.purchase(10, payment.source, options).tap do |response|
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
          expect(payment.source).to_not be_captured

          payment.payment_method.provider.refund(10, payment.source.order_id, options).tap do |response|
            expect(response).to be_a(ActiveMerchant::Billing::Response)
            payment.source.reload
            expect(payment.source).to be_captured
            expect(payment.source).to_not be_authorized
          end
        end
      end

      context "With missing configuration" do
        it "raises an error" do

          expect {
            ActiveMerchant::Billing::KlarnaGateway.new({})
          }.to raise_error(::KlarnaGateway::InvalidConfiguration)
        end
      end
    end
  end
end
