require "spec_helper"

module ActiveMerchant
  module Billing
    describe KlarnaGateway do
      extend KlarnaApiHelper

      within_a_virtual_api do
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
      end
    end
  end
end
