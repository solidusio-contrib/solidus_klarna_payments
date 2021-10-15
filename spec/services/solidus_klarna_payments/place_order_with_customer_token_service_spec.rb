# frozen_string_literal: true

require 'spec_helper'

describe SolidusKlarnaPayments::PlaceOrderWithCustomerTokenService do
  describe '#call' do
    subject(:service) { described_class.call(order: order, payment_source: payment_source) }

    let(:order) { create(:order_with_line_items) }
    let(:payment_method) { build(:klarna_credit_payment_method) }
    let(:payment_source) { build(:klarna_credit_payment, authorization_token: authorization_token, payment_method: payment_method) }

    let(:authorization_token) { 'AUTHORIZATION_TOKEN' }

    let(:klarna_payment_client) { instance_double('Klarna::Payment') }
    let(:klarna_customer_token_client) { instance_double('Klarna::CustomerToken') }

    # rubocop:disable RSpec/VerifiedDoubles
    # We can't use verified double since the Klarna::Response uses
    # the method missing to retrieve body data
    let(:customer_token_response) do
      double(
        'Klarna::Response',
        token_id: 'CUSTOMER_TOKEN'
      )
    end
    # rubocop:enable RSpec/VerifiedDoubles

    let(:customer_token_serializer) { instance_double('SolidusKlarnaPayments::CustomerTokenSerializer') }
    let(:order_serializer) { instance_double('SolidusKlarnaPayments::OrderSerializer') }

    before do
      allow(Klarna)
        .to receive(:client)
        .with(:payment)
        .and_return(klarna_payment_client)

      allow(klarna_payment_client)
        .to receive(:customer_token)
        .and_return(customer_token_response)

      allow(Klarna)
        .to receive(:client)
        .with(:customer_token)
        .and_return(klarna_customer_token_client)

      allow(klarna_customer_token_client)
        .to receive(:place_order)

      allow(SolidusKlarnaPayments::CustomerTokenSerializer)
        .to receive(:new)
        .and_return(customer_token_serializer)

      allow(SolidusKlarnaPayments::OrderSerializer)
        .to receive(:new)
        .and_return(order_serializer)

      allow(order_serializer)
        .to receive(:to_hash)
        .and_return({ serialized_order: 'yes' })

      allow(customer_token_serializer)
        .to receive(:to_hash)
        .and_return({ serialized_customer_token: 'yes' })

      allow(customer_token_response).to receive(:success?).and_return(true)

    context 'when the retrieve customer token method returns the customer token' do
      before do
        allow(SolidusKlarnaPayments.configuration.retrieve_customer_token_service_class)
          .to receive(:call)
          .and_return('CUSTOMER_TOKEN')
      end

      it 'calls the retrieve customer token class' do
        service

        expect(SolidusKlarnaPayments.configuration.retrieve_customer_token_service_class)
          .to have_received(:call)
      end

      it 'does not call the fetch customer token API' do
        service

        expect(klarna_payment_client)
          .not_to have_received(:customer_token)
      end
    end

    context 'when the retrieve customer token method returns nil' do
      before do
        allow(SolidusKlarnaPayments.configuration.retrieve_customer_token_service_class)
          .to receive(:call)
          .and_return(nil)
      end

      it 'calls the Klarna payment customer token method' do
        service

        expect(klarna_payment_client)
          .to have_received(:customer_token)
          .with(authorization_token, { serialized_customer_token: 'yes' })
      end
    end

    it 'calls the Klarna customer token place order method' do
      service

      expect(klarna_customer_token_client)
        .to have_received(:place_order)
        .with('CUSTOMER_TOKEN', { serialized_order: 'yes' })
    end
  end
end
