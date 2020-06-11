# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Order do
  subject(:order) { create(:order) }

  describe "#update_klarna_session(id)" do
    it 'sets the id and the expiry date in the future' do
      order.update_klarna_session(session_id: "abcdf", client_token: "abcdef")

      expect(order.klarna_session_id).to eq("abcdf")
      expect(order.klarna_client_token).to eq("abcdef")
      expect(order.klarna_session_expires_at).to be > DateTime.now
    end
  end

  describe "#klarna_session_expired?" do
    it 'check is session is expired' do
      expect(order.klarna_session_expired?).to be true
      order.update_klarna_session(session_id: "abcdf", client_token: "abcdef")
      expect(order.klarna_session_expired?).to be false
    end

    it "show expired session in the future" do
      expect(order.klarna_session_expired?).to be true
      order.update_klarna_session(session_id: "abcdf", client_token: "abcdef")
      order.klarna_session_expires_at = DateTime.now - 2.minutes
      expect(order.klarna_session_expired?).to be true
    end
  end

  describe "#update_klarna_session_time" do
    it 'extends the session time' do
      order.update_klarna_session(session_id: "abcdf", client_token: "abcdef")
      old_session = order.klarna_session_expires_at = DateTime.now - 2.minutes
      order.update_klarna_session_time
      expect(order.klarna_session_expires_at).not_to eq(old_session)
    end
  end

  describe "#to_klarna_hash" do
    it "returns a serialized hash for klarna" do
      expect(order.to_klarna).to be_a(SolidusKlarnaPayments::OrderSerializer)
    end
  end

  describe "#klarna_payments?", :klarna_api do
    it "checks when an order has klarna payments" do
      expect(check_order.payments.klarna_credit).not_to be_any
      expect(credit_card_order.payments.klarna_credit).not_to be_any
      expect(klarna_order.payments.klarna_credit).to be_any
    end
  end

  describe "#authorized_klarna_payments" do
    let(:order) { create(:order) }

    let(:payment) do
      create(:klarna_payment, order: order).tap do |payment|
        payment.source.update(payment_method_id: payment.payment_method.id)
      end
    end

    it "returns klarna payments with AUTHORIZED status" do
      expect(order.payments.count).to eq(0)
      expect(order.authorized_klarna_payments.count).to eq(0)

      payment && order.reload

      payment.source.update(status: 'AUTHORIZED')
      expect(order.authorized_klarna_payments.count).to eq(1)
    end

    it "returns klarna payements with CAPTURED status" do
      expect(order.payments.count).to eq(0)
      expect(order.captured_klarna_payments.count).to eq(0)

      payment && order.reload

      payment.source.update(status: 'CAPTURED')
      expect(order.captured_klarna_payments.count).to eq(1)

      payment.source.update(status: 'PART_CAPTURED')
      expect(order.captured_klarna_payments.count).to eq(1)

      payment.source.update(status: 'AUTHORIZED')
      expect(order.captured_klarna_payments.count).to eq(0)
    end
  end

  describe "#captured_klarna_payments", :klarna_api do
    it "returns klarna payements with CAPTURED status" do
      expect(klarna_order.captured_klarna_payments.count).to eq(0)

      payment.source.update(status: 'CAPTURED')
      expect(klarna_order.captured_klarna_payments.count).to eq(1)

      payment.source.update(status: 'PART_CAPTURED')
      expect(klarna_order.captured_klarna_payments.count).to eq(1)

      payment.source.update(status: 'AUTHORIZED')
      expect(klarna_order.captured_klarna_payments.count).to eq(0)
    end
  end

  describe "#can_be_cancelled_from_klarna?", :klarna_api do
    it "check if there is non cancelled payments" do
      payment.source.update(status: 'CAPTURED')
      expect(klarna_order.can_be_cancelled_from_klarna?).to eq(false)

      payment.source.update(status: 'PART_CAPTURED')
      expect(klarna_order.can_be_cancelled_from_klarna?).to eq(false)

      payment.source.update(status: 'AUTHORIZED')
      expect(klarna_order.can_be_cancelled_from_klarna?).to eq(false)

      payment.source.update(status: 'CANCELLED')
      expect(klarna_order.can_be_cancelled_from_klarna?).to eq(true)
    end
  end
end
