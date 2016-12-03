require "spec_helper"

module ActiveMerchant
  module Billing
    describe KlarnaGateway do
      extend KlarnaApiHelper

      within_a_virtual_api do
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
      end
    end
  end
end
