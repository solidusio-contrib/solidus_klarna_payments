require 'spec_helper'


describe KlarnaGateway::Payment::Processing, :klarna_api do

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
      allow(payment).to receive(:payment_provider).and_return(api_client)

      expect(payment.klarna_order).to eq(klarna_order_response.body)
    end
  end

  context "#refresh!" do
    it "calls the api to update the source" do
      expect(payment.send(:payment_provider)).to receive(:get_and_update_source).with(payment.source.order_id).and_return(true)
      payment.refresh!
    end
  end

  context "#extend_period!" do
    it "calls the api to extend credit authorization period" do
      expect(payment.send(:payment_provider)).to receive(:extend_period).with(payment.source.order_id).and_return(true)
      payment.extend_period!
    end
  end

  context "#release!" do
    it "calls the api to release remaining amount" do
      expect(payment.send(:payment_provider)).to receive(:release).with(payment.source.order_id).and_return(true)
      payment.release!
    end
  end

  context "#is_klarna?" do
    let(:check) { create(:check_payment) }

    it "checks if is a klarna payment" do
      expect(payment.is_klarna?).to be true
      expect(check.is_klarna?).to be false
    end

    context "#is_valid_klarna?" do
      let(:check) { create(:check_payment) }

      it "checks if is a valid klarna payment" do
        expect(payment.is_valid_klarna?).to be true
        expect(check.is_klarna?).to be false
      end
    end

    context "#notify!(params)" do
      it "logs the response from an API notification" do
        expect(ActiveMerchant::Billing::Response).to receive(:new).with(any_args).and_return({})
        expect(payment).to receive(:record_response).with({}).and_return(true)
        payment.notify!({
          klarna: {
            order_id: 123
          }
        })

      end
    end
  end
end
