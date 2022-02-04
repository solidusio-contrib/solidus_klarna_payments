# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusKlarnaPayments::CreateSessionOrderPresenter do
  describe '#serialized_order' do
    subject(:serialized_order) do
      described_class.new(
        order: order,
        klarna_payment_method: payment_method,
        store: Spree::Store.default,
        skip_personal_data: false
      ).serialized_order
    end

    let(:payment_method) { create(:klarna_credit_payment_method) }
    let(:order) { create(:order_with_line_items, state: 'payment', email: 'admin@example.com', user: user) }

    context 'when the payment method tokenize is set to true' do
      before do
        allow(Spree::Config).to receive(:[]).and_call_original

        allow(Spree::Config)
          .to receive(:[])
          .with(:allow_guest_checkout)
          .and_return(false)

        payment_method.preferred_tokenization = true
        payment_method.save!
      end

      context 'when the order is a guest order' do
        let(:user) { nil }

        it 'returns the intent set to BUY' do
          expect(serialized_order.to_hash[:intent]).to eq('BUY')
        end
      end

      context 'when the order is not a guest order' do
        let(:user) { create(:user) }

        it 'returns the intent set to TOKENIZE' do
          expect(serialized_order.to_hash[:intent]).to eq('TOKENIZE')
        end
      end
    end

    context 'when the payment method tokenize is set to false' do
      let(:user) { create(:user) }

      it 'returns the hash without the intent set' do
        expect(serialized_order.to_hash[:intent]).to eq('BUY')
      end
    end
  end
end
