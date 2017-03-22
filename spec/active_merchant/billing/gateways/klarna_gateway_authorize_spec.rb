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
    end
  end
end
