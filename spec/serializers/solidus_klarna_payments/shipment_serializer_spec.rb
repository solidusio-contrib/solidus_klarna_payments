# frozen_string_literal: true

require 'spec_helper'

describe SolidusKlarnaPayments::ShipmentSerializer do
  let(:shipment) { create(:shipment) }
  let(:us_strategy) { SolidusKlarnaPayments::AmountCalculators::Us::ShipmentCalculator.new }

  it "serialize the shipping name" do
    described_class.new(shipment, us_strategy).to_hash.tap do |data|
      expect(data[:name]).to eq(shipment.shipping_method.name)
    end
  end
end
