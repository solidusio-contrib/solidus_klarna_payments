# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusKlarnaPayments::Api::SessionsController do
  describe '#create' do
    subject(:make_request) { post '/solidus_klarna_payments/api/sessions', params: order_params }

    let(:order_params) do
      {
        order_token: order.guest_token,
        klarna_payment_method_id: payment_method.id,
        format: :json
      }
    end
    let!(:order) { create(:order_with_line_items, state: 'payment', user: user) }
    let(:payment_method) { create(:klarna_credit_payment_method) }
    let(:user) { create(:user) }

    before do
      login_as user

      allow(SolidusKlarnaPayments::CreateOrUpdateKlarnaSessionService)
        .to receive(:call)
        .and_return('TOKEN')
    end

    it 'calls the create or update klarna session service' do
      make_request

      expect(SolidusKlarnaPayments::CreateOrUpdateKlarnaSessionService)
        .to have_received(:call)
        .with(
          order: order,
          klarna_payment_method: payment_method,
          store: Spree::Store.default
        )
    end

    it 'returns the session token' do
      make_request

      expect(JSON.parse(response.body)['token']).to eq('TOKEN')
    end
  end
end
