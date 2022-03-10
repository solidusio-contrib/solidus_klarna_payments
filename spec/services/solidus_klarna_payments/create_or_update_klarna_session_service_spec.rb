# frozen_string_literal: true

require 'spec_helper'

describe SolidusKlarnaPayments::CreateOrUpdateKlarnaSessionService do
  describe '#call' do
    subject(:service) do
      described_class
        .call(
          order: order,
          klarna_payment_method: payment_method,
          store: store
        )
    end

    let(:payment_method) { create(:klarna_credit_payment_method) }
    let(:order) { create(:order_with_line_items, state: 'payment') }

    let(:store) { Spree::Store.default }

    let(:gateway) { instance_double('ActiveMerchant::Billing::KlarnaGateway') }
    let(:order_presenter) { instance_double('SolidusKlarnaPayments::CreateSessionOrderPresenter') }

    before do
      allow(SolidusKlarnaPayments::CreateSessionOrderPresenter)
        .to receive(:new)
        .and_return(order_presenter)

      allow(order_presenter).to receive(:to_hash).and_return({ order_params: 'order_params' })
      allow(payment_method).to receive(:gateway).and_return(gateway)
    end

    context 'when the klarna token is not present' do
      # rubocop:disable RSpec/VerifiedDoubles
      # We can't use verified double since the Klarna::Response uses
      # the method missing to retrieve body data
      let(:klarna_response) { double('Klarna::Response') }
      # rubocop:enable RSpec/VerifiedDoubles

      before do
        allow(gateway)
          .to receive(:create_session)
          .and_return(klarna_response)
      end

      context 'when the request is successfully' do
        before do
          allow(klarna_response).to receive(:success?).and_return(true)
          allow(klarna_response).to receive(:session_id).and_return('session_id')
          allow(klarna_response).to receive(:client_token).and_return('client_token')

          allow(order).to receive(:update_klarna_session)
          allow(order).to receive(:klarna_client_token).and_return(nil, 'client_token')
        end

        it 'returns the client token' do
          expect(service).to eq('client_token')
        end

        it 'calls the gateway create session method' do
          service

          expect(gateway)
            .to have_received(:create_session)
            .with({ order_params: 'order_params' })
        end

        it 'calls the order update klarna session method' do
          service

          expect(order)
            .to have_received(:update_klarna_session)
            .with(
              session_id: 'session_id',
              client_token: 'client_token'
            )
        end
      end

      context 'when the request is not successufully' do
        before do
          allow(klarna_response).to receive(:success?).and_return(false)
          allow(klarna_response).to receive(:inspect).and_return('exception')
        end

        it 'raises a create or update klarna session error' do
          expect { service }
            .to raise_error(
              SolidusKlarnaPayments::CreateOrUpdateKlarnaSessionService::CreateOrUpdateKlarnaSessionError
            )
        end
      end
    end

    context 'when the klarna token is present' do
      # rubocop:disable RSpec/VerifiedDoubles
      # We can't use verified double since the Klarna::Response uses
      # the method missing to retrieve body data
      let(:klarna_response) { double('Klarna::Response') }
      # rubocop:enable RSpec/VerifiedDoubles

      before do
        allow(order).to receive(:klarna_session_expired?).and_return(false)
        allow(order).to receive(:klarna_session_id).and_return('klarna_session_id')

        allow(gateway)
          .to receive(:update_session)
          .and_return(klarna_response)
      end

      context 'when the request is successfully' do
        before do
          allow(klarna_response).to receive(:success?).and_return(true)

          allow(order).to receive(:update_klarna_session_time)
          allow(order).to receive(:klarna_client_token).and_return('client_token')
        end

        it 'returns the client token' do
          expect(service).to eq('client_token')
        end

        it 'calls the gateway update session method' do
          service

          expect(gateway)
            .to have_received(:update_session)
            .with('klarna_session_id', { order_params: 'order_params' })
        end

        it 'calls the order update klarna session time' do
          service

          expect(order)
            .to have_received(:update_klarna_session_time)
        end
      end

      context 'when the request is not successufully' do
        before do
          allow(order).to receive(:klarna_client_token).and_return('client_token').once
          allow(klarna_response).to receive(:success?).and_return(false)
          allow(klarna_response).to receive(:inspect).and_return('exception')
        end

        it 'raises a create or update klarna session error' do
          expect { service }
            .to raise_error(
              SolidusKlarnaPayments::CreateOrUpdateKlarnaSessionService::CreateOrUpdateKlarnaSessionError
            )
        end
      end
    end
  end
end
