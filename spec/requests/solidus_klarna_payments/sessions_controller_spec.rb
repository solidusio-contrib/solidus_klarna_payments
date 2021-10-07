# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusKlarnaPayments::SessionsController do
  describe '#create' do
    subject(:request) { post '/solidus_klarna_payments/sessions', params: { klarna_payment_method_id: payment_method.id } }

    let!(:payment_method) { Spree::PaymentMethod::KlarnaCredit.create(name: 'Klarna') }
    let!(:order) { create(:order_with_line_items, state: 'payment', user: user) }

    let(:user) { create(:user) }

    before do
      login_as user

      payment_method.preferred_api_key = klarna_credentials[:key]
      payment_method.preferred_api_secret = klarna_credentials[:secret]
      payment_method.preferred_country = 'us'
      payment_method.save

      allow(controller).to receive(:current_order).and_return(order)
    end

    context 'with expired Klarna session', :vcr do
      it 'updates the order' do
        request
        expect(order.reload.klarna_client_token).to be_present
        expect(order.klarna_session_id).to be_present
        expect(order.klarna_session_expired?).to eq(false)
      end

      it 'outputs the client token' do
        request
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
          request
        }.to raise_error("Could not create or update Klarna session for order '#{order.number}'.")
      end
    end
  end
end
