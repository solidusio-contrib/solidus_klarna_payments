require "spec_helper.rb"

class TestingController
  include KlarnaGateway::NotificationsController

  def render(*params)

  end
end

describe KlarnaGateway::NotificationsController do
  extend KlarnaApiHelper

  within_a_virtual_api do

    subject { TestingController.new }

    it "accepts a klarna payment on API notification" do
      klarna_order.payments.first.tap do |payment|
        expect(subject).to receive(:params).at_least(:once).and_return({klarna: { order_id: payment.source.order_id, event_type: 'FRAUD_RISK_ACCEPTED' }})
        subject.notification

        expect(payment.source.reload).to be_accepted
      end
    end

    it "rejects a klarna payment on API notification" do
      klarna_order.payments.first.tap do |payment|
        expect(subject).to receive(:params).at_least(:once).and_return({klarna: { order_id: payment.source.order_id, event_type: 'FRAUD_RISK_REJECTED' }})
        subject.notification

        expect(payment.source.reload).to be_rejected
      end
    end

    it "stops a klarna payment on API notification" do
      klarna_order.payments.first.tap do |payment|
        expect(subject).to receive(:params).at_least(:once).and_return({klarna: { order_id: payment.source.order_id, event_type: 'FRAUD_RISK_STOPPED' }})
        subject.notification

        expect(payment.source.reload).to be_rejected
      end
    end
  end
end
