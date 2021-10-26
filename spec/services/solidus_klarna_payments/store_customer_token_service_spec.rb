# frozen_string_literal: true

require 'spec_helper'

describe SolidusKlarnaPayments::StoreCustomerTokenService do
  describe '#call' do
    subject(:service) { described_class.call(order: order, customer_token: customer_token) }

    let(:order) { create(:order_with_line_items, user: user) }
    let(:customer_token) { 'CUSTOMER_TOKEN' }

    context 'when the order has a user' do
      let(:user) { create(:user) }

      it 'updates the user token' do
        expect { service }
          .to change { user.reload.klarna_customer_token }.to(customer_token)
      end

      it { is_expected.to be_truthy }
    end

    context 'when the order does not have a user' do
      let(:user) { nil }

      it { is_expected.to be_falsey }
    end
  end
end
