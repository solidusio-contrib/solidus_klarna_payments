# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Admin::PaymentMethodsController do
  describe '#create' do
    subject(:request) do
      post(
        '/admin/payment_methods',
        params: {
          payment_method: {
            name: 'Test Klarna Method',
            type: 'Spree::PaymentMethod::KlarnaCredit',
          },
        }
      )
    end

    before { login_as create(:admin_user) }

    it 'creates a Klarna payment method' do
      expect {
        request
      }.to change(Spree::PaymentMethod, :count).by(1)
    end
  end

  describe '#update' do
    subject(:request) do
      patch(
        "/admin/payment_methods/#{payment_method.id}",
        params: build_update_attributes(
          payment_method,
          preferred_api_key: preferred_api_key,
          preferred_api_secret: preferred_api_secret
        )
      )
    end

    let(:payment_method) { create(:klarna_credit_payment_method) }

    before { login_as create(:admin_user) }

    context 'when passing empty credentials', vcr: 'payment methods controller update with no credentials' do
      let(:preferred_api_key) { nil }
      let(:preferred_api_secret) { nil }

      before { request }

      it 'renders an error' do
        expect(flash[:error]).to match(/can not be tested/)
        expect(flash[:success]).to match(/successfully updated/)
      end
    end

    context 'when passing invalid credentials' do
      let(:preferred_api_key) { 'invalid' }
      let(:preferred_api_secret) { 'invalid' }

      before { request }

      it 'renders an error' do
        expect(flash[:error]).to match(/invalid/)
        expect(flash[:success]).to match(/successfully updated/)
      end
    end

    context 'when passing valid credentials' do
      let(:preferred_api_key) { klarna_credentials[:key] }
      let(:preferred_api_secret) { klarna_credentials[:secret] }

      before { request }

      it 'renders a success message' do
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
