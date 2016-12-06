module KlarnaApiHelper
  def within_a_virtual_api(&block)
    let!(:a_successful_response) do
       -> (double) {
        allow(double).to receive(:success?).and_return(true)
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
        body: {},
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

    yield
  end
end
