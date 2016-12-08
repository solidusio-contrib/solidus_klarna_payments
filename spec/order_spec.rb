require 'spec_helper'

class Order
  include KlarnaGateway::Order
  attr_accessor :klarna_session_id, :klarna_client_token, :klarna_session_expires_at

  def update_attributes(attributes)
    @klarna_session_id = attributes[:klarna_session_id] if attributes[:klarna_session_id]
    @klarna_client_token = attributes[:klarna_client_token] if attributes[:klarna_client_token]
    @klarna_session_expires_at = attributes[:klarna_session_expires_at] if attributes[:klarna_session_expires_at]
  end

  def reload
    self
  end
end

describe KlarnaGateway::Order do

  subject(:order) { Order.new }

  context "#update_klarna_session(id)" do
    it 'sets the id and the expiry date in the future' do
      expect_any_instance_of(Order).to receive(:update_attributes).and_call_original
      order.update_klarna_session(session_id: "abcdf", client_token: "abcdef")
      expect(order.klarna_session_id).to eq("abcdf")
      expect(order.klarna_client_token).to eq("abcdef")
      expect(order.klarna_session_expires_at).to be > DateTime.now
    end
  end

  context "#klarna_session_expired?" do
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

  context "#update_klarna_session_time" do
    it 'extends the session time' do
      order.update_klarna_session(session_id: "abcdf", client_token: "abcdef")
      old_session = order.klarna_session_expires_at = DateTime.now - 2.minutes
      order.update_klarna_session_time
      expect(order.klarna_session_expires_at).to_not eq(old_session)
    end
  end

  context "#to_klarna_hash" do
    it "returns a serialized hash for klarna" do
      expect(order.to_klarna).to be_a(KlarnaGateway::OrderSerializer)
    end
  end

  context "#authorized_klarna_payments" do
    let(:order) { create(:order) }

    let(:payment) do
      create(:klarna_payment, order: order).tap do |payment|
        payment.source.update_attributes(payment_method_id: payment.payment_method.id)
      end
    end

    it "returns klarna payments with AUTHORIZED status" do
      expect(order.payments.count).to eq(0)
      expect(order.authorized_klarna_payments.count).to eq(0)

      payment && order.reload

      payment.source.update_attributes(status: 'AUTHORIZED')
      expect(order.authorized_klarna_payments.count).to eq(1)
    end

    it "returns klarna payements with CAPTURED status" do
      expect(order.payments.count).to eq(0)
      expect(order.captured_klarna_payments.count).to eq(0)

      payment && order.reload

      payment.source.update_attributes(status: 'CAPTURED')
      expect(order.captured_klarna_payments.count).to eq(1)

      payment.source.update_attributes(status: 'PART_CAPTURED')
      expect(order.captured_klarna_payments.count).to eq(1)

      payment.source.update_attributes(status: 'AUTHORIZED')
      expect(order.captured_klarna_payments.count).to eq(0)
    end

  end
end
