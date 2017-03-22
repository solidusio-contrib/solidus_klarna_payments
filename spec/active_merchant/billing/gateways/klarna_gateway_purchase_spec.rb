require "spec_helper"

module ActiveMerchant
  module Billing
    describe KlarnaGateway, :klarna_api do

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
    end
  end
end
