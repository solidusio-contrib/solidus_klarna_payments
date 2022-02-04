# frozen_string_literal: true

require 'spec_helper'

describe ActiveMerchant::Billing::KlarnaGateway do
  let(:gateway) { described_class.new(options) }
  let(:options) do
    {
      api_key: ENV.fetch('SOLIDUS_KLARNA_PAYMENTS_API_KEY', 'DUMMY'),
      api_secret: ENV.fetch('SOLIDUS_KLARNA_PAYMENTS_API_SECRET', 'DUMMY'),
      test_mode: true,
      country: :us
    }
  end

  describe '#authorize' do
    subject(:authorize) { gateway.authorize(1000, payment_source, gateway_options) }

    let(:order) { create(:order_with_line_items) }
    let(:payment_method) { build(:klarna_credit_payment_method) }

    let(:payment_source) do
      build(
        :klarna_credit_payment,
        authorization_token: authorization_token,
        payment_method: payment_method,
        order: order
      )
    end

    let(:gateway_options) { { order_id: "#{order.number}-somestuff" } }
    let(:authorization_token) { 'AUTHORIZATION_TOKEN' }
    let(:response_success) { true }

    # rubocop:disable RSpec/VerifiedDoubles
    # We can't use verified double since the Klarna::Response uses
    # the method missing to retrieve body data
    let(:response) do
      double(
        'Klarna::Response',
        error_code: -1,
        error_messages: 'error_messages',
        correlation_id: -1,
        order_id: 'order_id',
        body: {},
        fraud_status: 'fraud_status'
      )
    end

    let(:get_order_response) do
      double(
        'Klarna::Response',
        status: 'status',
        fraud_status: 'fraud_status',
        expires_at: '1970-01-01'
      )
    end
    # rubocop:enable RSpec/VerifiedDoubles

    let(:klarna_client) { instance_double('Klarna::Order') }

    before do
      allow(::SolidusKlarnaPayments::PlaceOrderService)
        .to receive(:call)
        .and_return(response)

      allow(Klarna).to receive(:client).and_return(klarna_client)
      allow(klarna_client).to receive(:get).and_return(get_order_response)

      allow(response).to receive(:success?).and_return(response_success)
    end

    context 'when the order is get using the passed gateway options' do
      it 'calls the place order with authorization token service' do
        authorize
        expect(::SolidusKlarnaPayments::PlaceOrderService)
          .to have_received(:call)
          .with(order: order, payment_source: payment_source)
      end
    end

    context 'when the order is get using the originator' do
      let(:gateway_options) { { originator: payment_source } }

      it 'calls the place order with authorization token service' do
        authorize
        expect(::SolidusKlarnaPayments::PlaceOrderService)
          .to have_received(:call)
          .with(order: order, payment_source: payment_source)
      end
    end

    context 'when the order cannot be retrieved' do
      let(:gateway_options) { {} }

      it 'raises a not found error' do
        expect { authorize }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'returns a successful response' do
      expect(authorize).to be_success
    end

    context 'with a wrong authorization token' do
      let(:response_success) { false }

      it 'returns a unsuccesfull response' do
        expect(authorize).not_to be_success
      end
    end
  end

  describe '#create_profile' do
    subject(:create_profile) { gateway.create_profile(payment) }

    let(:order) { create(:order_with_line_items) }
    let(:payment_method) { build(:klarna_credit_payment_method) }
    let(:payment) { build(:klarna_payment, source: payment_source) }

    let(:payment_source) do
      create(
        :klarna_credit_payment,
        authorization_token: authorization_token,
        payment_method: payment_method,
        customer_token: initial_customer_token,
        order: order
      )
    end

    let(:gateway_options) { { order_id: "#{order.number}-somestuff" } }
    let(:authorization_token) { 'AUTHORIZATION_TOKEN' }
    let(:response_success) { true }
    let(:initial_customer_token) { nil }
    let(:customer_token) { 'CUSTOMER_TOKEN' }

    # rubocop:disable RSpec/VerifiedDoubles
    # We can't use verified double since the Klarna::Response uses
    # the method missing to retrieve body data
    let(:response) do
      double(
        'Klarna::Response',
        error_code: -1,
        error_messages: 'error_messages',
        correlation_id: -1,
        order_id: 'order_id',
        body: {},
        fraud_status: 'fraud_status'
      )
    end

    before do
      allow(SolidusKlarnaPayments::CreateCustomerTokenService).to receive(:call).and_return(customer_token)
    end

    it 'calls the service to create the customer token' do
      create_profile

      expect(SolidusKlarnaPayments::CreateCustomerTokenService).to have_received(:call).with(
        order: payment.order,
        authorization_token: authorization_token,
        region: payment.payment_method.preferred_country
      )
    end

    it 'updates the customer_token on the source' do
      expect { create_profile }.to change(payment_source.reload, :customer_token).from(nil).to(customer_token)
    end

    context 'when customer_token is already present on the source' do
      let(:initial_customer_token) { 'Initial-customer-token' }

      it 'does not call the service to create the customer token' do
        create_profile

        expect(SolidusKlarnaPayments::CreateCustomerTokenService).not_to have_received(:call)
      end

      it 'updates the customer_token on the source' do
        expect { create_profile }.not_to change(payment_source.reload, :customer_token).from(initial_customer_token)
      end
    end

    context 'when Spree::Order#klarna_tokenizable? is false' do
      before { allow(payment.order).to receive(:klarna_tokenizable?).and_return(false) }

      it 'does not call the service to create the customer token' do
        create_profile

        expect(SolidusKlarnaPayments::CreateCustomerTokenService).not_to have_received(:call)
      end

      it 'updates the customer_token on the source' do
        expect { create_profile }.not_to change(payment_source.reload, :customer_token).from(initial_customer_token)
      end
    end
  end
end
