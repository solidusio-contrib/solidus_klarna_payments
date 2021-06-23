# frozen_string_literal: true

require "spec_helper"

RSpec.describe Spree::Admin::PaymentMethodsController do
  stub_authorization!

  describe '#create' do
    it 'creates a Klarna payment method' do
      expect {
        post :create, params: {
          payment_method: {
            name: 'Test Klarna Method',
            type: 'Spree::PaymentMethod::KlarnaCredit',
          },
        }
      }.to change(Spree::PaymentMethod, :count).by(1)
    end
  end

  describe '#update' do
    context 'when passing empty credentials' do
      it 'renders an error' do
        payment_method = create(:klarna_credit_payment_method)

        VCR.use_cassette('payment methods controller update with no credentials') do
          patch :update, params: build_update_attributes(payment_method,
            preferred_api_key: nil,
            preferred_api_secret: nil,)
        end

        expect(flash[:error]).to match(/can not be tested/)
        expect(flash[:success]).to match(/successfully updated/)
      end
    end

    context 'when passing invalid credentials' do
      it 'renders an error' do
        payment_method = create(:klarna_credit_payment_method)

        VCR.use_cassette('payment methods controller update with invalid credentials') do
          patch :update, params: build_update_attributes(payment_method,
            preferred_api_key: 'invalid',
            preferred_api_secret: 'invalid',)
        end

        expect(flash[:error]).to match(/invalid/)
        expect(flash[:success]).to match(/successfully updated/)
      end
    end

    context 'when passing valid credentials' do
      it 'renders a success message' do
        payment_method = create(:klarna_credit_payment_method)

        VCR.use_cassette('payment methods controller update with valid credentials') do
          patch :update, params: build_update_attributes(payment_method,
            preferred_api_key: klarna_credentials[:key],
            preferred_api_secret: klarna_credentials[:secret],)
        end

        expect(flash[:notice]).to match(/configuration completed/)
        expect(flash[:success]).to match(/successfully updated/)
      end
    end

    private

    def build_update_attributes(payment_method, attributes)
      {
        payment_method: {
          name: 'Test Klarna Method',
          type: 'Spree::PaymentMethod::KlarnaCredit',
          preferred_country: 'us'
        }.merge(attributes),
        id: payment_method.to_param,
      }
    end
  end
end
