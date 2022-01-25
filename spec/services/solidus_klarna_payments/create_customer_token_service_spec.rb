# frozen_string_literal: true

require 'spec_helper'

describe SolidusKlarnaPayments::CreateCustomerTokenService do
  describe '#call' do
    subject(:service) do
      described_class
        .call(
          order: order,
          authorization_token: authorization_token,
          region: region
        )
    end

    let(:order) { create(:order_with_line_items) }
    let(:authorization_token) { 'AUTHORIZATION_TOKEN' }
    let(:region) { 'us' }
    let(:klarna_payment_client) { instance_double('Klarna::Payment') }
    let(:customer_token_response) do
      double('Klarna::Response', token_id: 'CUSTOMER_TOKEN') # rubocop:disable RSpec/VerifiedDoubles
    end
    let(:customer_token_serializer) { instance_double('SolidusKlarnaPayments::CustomerTokenSerializer') }
    let(:klarna_customer_token_client) { instance_double('Klarna::CustomerToken') }

    before do
      allow(Klarna)
        .to receive(:client)
        .with(:payment)
        .and_return(klarna_payment_client)

      allow(klarna_payment_client)
        .to receive(:customer_token)
        .and_return(customer_token_response)

      allow(klarna_customer_token_client)
        .to receive(:place_order)

      allow(SolidusKlarnaPayments::CustomerTokenSerializer)
        .to receive(:new)
        .and_return(customer_token_serializer)

      allow(customer_token_serializer)
        .to receive(:to_hash)
        .and_return({ serialized_customer_token: 'yes' })
    end

    it 'calls the Klarna payment customer token method' do
      service

      expect(klarna_payment_client)
        .to have_received(:customer_token)
        .with(authorization_token, { serialized_customer_token: 'yes' })
    end

    it 'returns the token id' do
      expect(service).to eq 'CUSTOMER_TOKEN'
    end

    it 'provides the right params to the CustomerTokenSerializer' do
      service

      expect(SolidusKlarnaPayments::CustomerTokenSerializer)
        .to have_received(:new).with(
          order: order,
          description: 'Customer token',
          region: region
        )
    end

    context 'when customer token response is nil' do
      let(:customer_token_response) { nil }

      it 'returns nil without raising any exception' do
        expect(service).to be_nil
      end
    end
  end
end
