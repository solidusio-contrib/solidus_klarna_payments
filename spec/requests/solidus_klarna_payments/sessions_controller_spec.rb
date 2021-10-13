# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusKlarnaPayments::SessionsController do
  describe '#create' do
    subject(:make_request) { post '/solidus_klarna_payments/sessions', params: { klarna_payment_method_id: payment_method.id } }

    let!(:payment_method) { create(:klarna_credit_payment_method) }
    let!(:order) { create(:order_with_line_items, state: 'payment', user: user) }

    let(:user) { create(:user) }

    before { login_as user }

    context 'with expired Klarna session', :vcr do
      it 'updates the order' do
        make_request
        expect(order.reload.klarna_client_token).to be_present
        expect(order.klarna_session_id).to be_present
        expect(order.klarna_session_expired?).to eq(false)
      end

      it 'outputs the client token' do
        make_request
        expect(JSON.parse(response.body)['token']).to eq(order.reload.klarna_client_token)
      end
    end

    context 'with an empty session_id', :vcr do
      let(:order) {
        create(
          :order_with_line_items,
          user: user,
          state: 'payment',
          klarna_session_id: '',
          klarna_client_token: '',
          klarna_session_expires_at: 15.minutes.from_now
        )
      }

      it 'raises an exception' do
        expect {
          make_request
        }.to raise_error("Could not create or update Klarna session for order '#{order.number}'.")
      end
    end

    it 'calls the create session order presenter', vcr: true do
      allow(SolidusKlarnaPayments::CreateSessionOrderPresenter)
        .to receive(:new)
        .and_call_original

      make_request

      expect(SolidusKlarnaPayments::CreateSessionOrderPresenter)
        .to have_received(:new)
        .with(
          order: a_kind_of(Spree::Order),
          klarna_payment_method: payment_method,
          store: Spree::Store.default,
          skip_personal_data: true
        )
    end
  end
end
