# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Admin::PaymentMethodsController do
  describe '#update' do
    subject(:make_request) do
      patch(
        "/admin/payment_methods/#{payment_method.id}",
        params: {
          id: payment_method.to_param,
          payment_method: {
            name: 'Test Klarna Method',
            type: type,
            preferred_country: 'us',
            preferred_api_key: 'API_KEY',
            preferred_api_secret: 'API_SECRET',
            preferred_test_mode: '0'
          }
        }
      )
    end

    let(:payment_method) { create(:klarna_credit_payment_method) }

    let(:type) { 'Spree::PaymentMethod::KlarnaCredit' }

    before do
      login_as create(:admin_user)
    end

    context 'when the validation returns true' do
      before do
        allow(SolidusKlarnaPayments::ValidateKlarnaCredentialsService)
          .to receive(:call)
          .and_return(true)
      end

      it 'calls the validate klarna credentials service' do
        make_request

        expect(SolidusKlarnaPayments::ValidateKlarnaCredentialsService)
          .to have_received(:call)
          .with(
            api_key: 'API_KEY',
            api_secret: 'API_SECRET',
            test_mode: '0',
            country: 'us'
          )
      end

      it 'renders a success message' do
        make_request

        expect(flash[:notice]).to match(/configuration completed/)
        expect(flash[:success]).to match(/successfully updated/)
      end
    end

    context 'when the validation raises a missing credential exception' do
      before do
        allow(SolidusKlarnaPayments::ValidateKlarnaCredentialsService)
          .to receive(:call)
          .and_raise(::SolidusKlarnaPayments::ValidateKlarnaCredentialsService::MissingCredentialsError)
      end

      it 'renders the cannot be tested error' do
        make_request

        expect(flash[:error]).to match(/can not be tested/)
        expect(flash[:success]).to match(/successfully updated/)
      end
    end

    context 'when the validation returns false' do
      before do
        allow(SolidusKlarnaPayments::ValidateKlarnaCredentialsService)
          .to receive(:call)
          .and_return(false)
      end

      it 'renders the invalid credentials error' do
        make_request

        expect(flash[:error]).to match(/invalid/)
        expect(flash[:success]).to match(/successfully updated/)
      end
    end

    context 'when the payment method type is not klarna' do
      let(:type) { 'Spree::PaymentMethod::CreditCard' }

      before do
        allow(SolidusKlarnaPayments::ValidateKlarnaCredentialsService)
          .to receive(:call)
      end

      it 'does not call the validate klarna credentials service' do
        make_request

        expect(SolidusKlarnaPayments::ValidateKlarnaCredentialsService)
          .not_to have_received(:call)
      end
    end
  end
end
