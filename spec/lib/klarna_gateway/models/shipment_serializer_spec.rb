require 'spec_helper'

describe KlarnaGateway::ShipmentSerializer do
  let(:shipment) { create(:shipment) }
  let(:us_strategy) { KlarnaGateway::AmountCalculators::US::ShipmentCalculator.new }

  it "serialize the shipping name" do
    described_class.new(shipment, us_strategy).to_hash.tap do |data|
      expect(data[:name]).to eq(shipment.shipping_method.name)
    end
  end
end
