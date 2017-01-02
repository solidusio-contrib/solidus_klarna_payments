RSpec.shared_context "Klarna API helper", :klarna_api do
  let!(:a_successful_response) do
     -> (double) {
      allow(double).to receive(:success?).and_return(true)
      allow(double).to receive(:[]).and_return("A-HEADER")
      allow(double).to receive(:error?).and_return(false)
      double
    }
  end

  let!(:a_error_response) do
     -> (double) {
      allow(double).to receive(:success?).and_return(false)
      allow(double).to receive(:error?).and_return(true)
      double
    }
  end

  let(:payment) do
    create(:klarna_payment).tap do |payment|
      payment.source.update_attributes(payment_method_id: payment.payment_method.id)
    end
  end

  let(:klarna_authorize_response) {
    a_successful_response.call double('ApiResponse',
      body: {},
      order_id: 1234,
      fraud_status: "ACCEPTED",
      redirect_url: "http://someplace.com"
    )
  }

  let(:klarna_order_response) {
    a_successful_response.call double('ApiResponse',
      body: {
        order_id: 1234,
        fraud_status: "ACCEPTED",
        status: "AUTHORIZED"
      },
      order_id: 1234,
      fraud_status: "ACCEPTED",
      status: "AUTHORIZED",
      expires_at: (DateTime.now + 6.days).to_s
    )
  }

  let(:klarna_negative_response) {
    a_error_response.call double('ApiResponse',
      body: {},
      error_code: "SOME_ERROR",
      error_messages: "some error",
      correlation_id: 1234
    )
  }

  let(:klarna_captured_response) {
    a_successful_response.call double('ApiResponse',
      body: {},
      order_id: 1234,
      fraud_status: "ACCEPTED",
      status: "CAPTURED",
      expires_at: (DateTime.now + 6.days).to_s
    )
  }

  let(:klarna_cancelled_response) {
    a_successful_response.call double('ApiResponse',
      body: {},
      order_id: 1234,
      fraud_status: "ACCEPTED",
      status: "CANCELLED",
      expires_at: (DateTime.now + 6.days).to_s
    )
  }

  let(:klarna_empty_success_response) {
    a_successful_response.call double('ApiResponse',
      body: {}
    )
  }

  let(:options) { {order_id: "#{payment.order.number}-123"}}

  let(:api_client) { double('KlarnaApi') }

  let(:order) { create(:order) }

  let(:klarna_order) do
    order.tap do |order|
      order.payments << payment
      order.save!
      payment.source.update_attributes(order: order)
    end
  end

  let(:check_order) do
    order.tap do |order|
      order.payments << create(:check_payment)
      order.save!
    end
  end

  let(:credit_card_order) do
    order.tap do |order|
      order.payments << create(:credit_card_payment)
      order.save!
    end
  end
end
