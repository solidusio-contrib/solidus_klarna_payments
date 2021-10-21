# frozen_string_literal: true

require 'spec_helper'

describe SolidusKlarnaPayments::ValidateKlarnaCredentialsService do
  describe '#call' do
    subject(:service) do
      described_class
        .call(
          api_key: api_key,
          api_secret: api_secret,
          test_mode: '0',
          country: 'us'
        )
    end

    let(:api_key) { 'API_KEY' }
    let(:api_secret) { 'API_SECRET' }
    let(:code) { '200' }

    let(:klarna_client) { instance_spy('Klarna::Payment') }
    let(:klarna_response) { instance_spy('Klarna::Response') }
    let(:http_error) { instance_spy('Net::HTTPClientError') }

    before do
      allow(Klarna).to receive(:configure)
      allow(Klarna).to receive(:client).and_return(klarna_client)
      allow(klarna_client).to receive(:create_session).and_return(klarna_response)
      allow(klarna_response).to receive(:http_response).and_return(http_error)
      allow(http_error).to receive(:code).and_return(code)
    end

    it 'calls the klarna configure method' do
      service

      expect(Klarna).to have_received(:configure)
    end

    it 'calls the klarna create session method' do
      service

      expect(klarna_client).to have_received(:create_session).with({})
    end

    context 'when the create session returns a 401 status code' do
      let(:code) { '401' }

      it { is_expected.to be_falsey }
    end

    context 'when the create session returns a 400 status code' do
      let(:code) { '400' }

      it { is_expected.to be_truthy }
    end

    context 'when the credentials were not passed' do
      let(:api_key) { nil }
      let(:api_secret) { nil }

      it 'raises a missing credentials exception' do
        expect { service }.to raise_error(
          SolidusKlarnaPayments::ValidateKlarnaCredentialsService::MissingCredentialsError
        )
      end
    end
  end
end
