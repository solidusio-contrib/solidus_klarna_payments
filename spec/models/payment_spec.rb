require 'spec_helper'


describe KlarnaGateway::Payment do
  extend KlarnaApiHelper
  within_a_virtual_api do

    context "delegating method to the source" do
      it "delegates can_ methods to the source" do
        [:can_refresh?, :can_extend_period?, :can_capture?, :can_cancel?, :can_release?].methods do |method|
          expect(payment.source).to receive(method).with(any_args).and_return(true)
          payment.send(method)
        end
      end
    end

    context "#klarna_order" do
      it "calls the api to get the order" do
        allow(api_client).to receive(:get).with(any_args).and_return(klarna_order_response)
        allow(payment).to receive(:provider).and_return(api_client)

        expect(payment.klarna_order).to eq(klarna_order_response.body)
      end
    end

    context "#refresh!" do
      it "calls the api to update the source" do
        expect(payment.send(:provider)).to receive(:get_and_update_source).with(payment.source.order_id).and_return(true)
        payment.refresh!
      end
    end

    context "#approve!" do
      it "calls the api to approve or acknowledge the source" do
        expect(payment.send(:provider)).to receive(:acknowledge).with(payment.source.order_id).and_return(true)
        payment.approve!
      end
    end

    context "#extend_period!" do
      it "calls the api to extend credit authorization period" do
        expect(payment.send(:provider)).to receive(:extend).with(payment.source.order_id).and_return(true)
        payment.extend_period!
      end
    end

    context "#release!" do
      it "calls the api to release remaining amount" do
        expect(payment.send(:provider)).to receive(:release).with(payment.source.order_id).and_return(true)
        payment.release!
      end
    end

    context "#cancel!" do
      it "calls the api to cancel the order and voids the order" do
        expect(payment.send(:provider)).to receive(:cancel).with(payment.source.order_id).and_return(true)
        expect(payment).to receive(:void!).and_return(true)
        payment.cancel!
      end
    end

    context "#is_klarna?" do
      let(:check) { create(:check_payment) }

      it "checks if is a klarna payment" do
        expect(payment.is_klarna?).to be true
        expect(check.is_klarna?).to be false
      end
    end
  end
end
