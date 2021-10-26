# frozen_string_literal: true

require 'spec_helper'

describe SolidusKlarnaPayments::RetrieveCustomerTokenService do
  describe '#call' do
    subject(:service) { described_class.call(order: order) }

    let(:order) { create(:order_with_line_items, user: user) }

    context 'when the order has a user' do
      let(:user) { create(:user) }

      context 'when the user has a token set' do
        before { user.update!(klarna_customer_token: 'TOKEN') }

        it 'returns the customer token' do
          expect(service).to eq('TOKEN')
        end
      end

      context 'when the user does not have a token set' do
        it { is_expected.to be_nil }
      end
    end

    context 'when the order does not have a user' do
      let(:user) { nil }

      it { is_expected.to be_nil }
    end
  end
end
