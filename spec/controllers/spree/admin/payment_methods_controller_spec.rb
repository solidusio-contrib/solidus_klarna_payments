require "spec_helper"

Spree::Admin::PaymentMethodsController.include(KlarnaGateway::Admin::PaymentMethodsController)

describe Spree::Admin::PaymentMethodsController do
  include Devise::Test::ControllerHelpers
  stub_authorization!

  describe "#validate_klarna_credentials" do
    context "Create" do
      it "Creates a Klarna Payment Method" do
        expect {
          spree_post :create, payment_method: { name: "Test Klarna Method", type: "Spree::Gateway::KlarnaCredit" }
        }.to change(Spree::PaymentMethod, :count).by(1)

        expect(response).to be_redirect
      end
    end

    context "Update" do
      let(:payment_method) { create(:klarna_credit_payment_method) }
      let(:attributes) do
        {  _method: "patch",
          payment_method: {
           name: "Test Klarna Method",
          type: "Spree::Gateway::KlarnaCredit" },
          gateway_klarna_credit: {
            preferred_api_key: '123',
            preferred_api_secret: '123',
            preferred_country: 'us'
          },
          id: payment_method.to_param
        }
      end

      it "updates with no credentials" do
        attributes[:gateway_klarna_credit][:preferred_api_key] = nil
        attributes[:gateway_klarna_credit][:preferred_api_secret] = nil

        VCR.use_cassette('payment methods controller update with no credentials') do
          spree_put(:update, attributes)
        end

        expect(flash[:error]).to match(/can not be tested/)
        expect(flash[:success]).to match(/successfully updated/)
      end

      it "updates with invalid credentials" do
        VCR.use_cassette('payment methods controller update with invalid credentials') do
          spree_put(:update, attributes)
        end

        expect(flash[:error]).to match(/not valid/)
        expect(flash[:success]).to match(/successfully updated/)
      end

      it "updates with valid credentials" do
        attributes[:gateway_klarna_credit][:preferred_api_key] = current_store_keys['key']
        attributes[:gateway_klarna_credit][:preferred_api_secret] = current_store_keys['secret']

        VCR.use_cassette('payment methods controller update with valid credentials') do
          spree_put(:update, attributes)
        end

        expect(flash[:notice]).to match(/configuration completed/)
        expect(flash[:success]).to match(/successfully updated/)
      end
    end
  end
end



