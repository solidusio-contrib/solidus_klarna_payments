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

    let!(:payment_method) { create(:klarna_credit_payment_method) }
    let!(:order) { create(:order_with_line_items, state: 'payment') }

    context 'when the payment method tokenize is set to true' do
      before do
        payment_method.preferred_tokenization = true
        payment_method.save!
      end

      it 'returns the intent set to TOKENIZE' do
        expect(serialized_order.to_hash[:intent]).to eq('TOKENIZE')
      end
    end

    context 'when the payment method tokenize is set to false' do
      it 'returns the hash without the intent set' do
        expect(serialized_order.to_hash).not_to include('intent')
      end
    end
  end
end
