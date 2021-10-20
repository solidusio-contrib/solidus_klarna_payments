# frozen_string_literal: true

require 'spec_helper'

describe Spree::PaymentMethod::KlarnaCredit do
  describe 'capture', :klarna_api do
    subject(:capture) { payment_method.capture(amount, klarna_order_id, order_id: "#{order.number}-dummy") }

    let(:payment_method) { create(:klarna_credit_payment_method) }
    let(:order) { create(:order_with_line_items) }

    let(:gateway) { instance_spy('ActiveMerchant::Billing::KlarnaGateway') }
    let(:order_serializer) { instance_spy('SolidusKlarnaPayments::OrderSerializer') }

    let(:amount) { 100 }
    let(:klarna_order_id) { 'KLARNA_ORDER_ID' }

    before do
      allow(payment_method).to receive(:gateway).and_return(gateway)
      allow(gateway).to receive(:capture)

      allow(SolidusKlarnaPayments::OrderSerializer)
        .to receive(:new)
        .and_return(order_serializer)

      allow(order_serializer).to receive(:to_hash).and_return({ shipping_info: 'shipping_info' })
    end

    it 'does not error' do
      expect {
        capture
      }.not_to raise_error
    end

    it 'calls the gateway capture method' do
      capture

      expect(gateway)
        .to have_received(:capture)
        .with(amount, 'KLARNA_ORDER_ID', { order_id: "#{order.number}-dummy", shipping_info: 'shipping_info' })
    end

    it 'calls the order serializer' do
      capture

      expect(SolidusKlarnaPayments::OrderSerializer)
        .to have_received(:new)
        .with(order, :us)
    end
  end

  describe 'tokenization_flow validation' do
    subject(:valid) { payment_method.valid? }

    let(:payment_method) { create(:klarna_credit_payment_method) }

    context 'when the tokenization flow is disabled' do
      before do
        payment_method.preferred_tokenization = false
      end

      it { is_expected.to be_truthy }
    end

    context 'when the tokenization flow is enabled' do
      before do
        payment_method.preferred_tokenization = true
      end

      context 'when guest checkout is enabled' do
        before do
          allow(Spree::Config).to receive(:[]).and_call_original

          allow(Spree::Config)
            .to receive(:[])
            .with(:allow_guest_checkout)
            .and_return(true)\
        end

        it { is_expected.to be_falsey }
      end

      context 'when the guest checkout is disabled' do
        before do
          allow(Spree::Config).to receive(:[]).and_call_original

          allow(Spree::Config)
            .to receive(:[])
            .with(:allow_guest_checkout)
            .and_return(false)
        end

        it { is_expected.to be_truthy }
      end
    end
  end
end
