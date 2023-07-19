# frozen_string_literal: true

require "spec_helper"

describe SolidusKlarnaPayments::AddressSerializer do
  subject(:serialized) { serializer.to_hash }

  let(:serializer) { described_class.new(address) }
  let(:address) { create(:address, state: state, country: country) }
  let(:country) { create(:country, iso: "DE") }
  let(:state) { create(:state, country: country) }

  # regression test
  it "sets the region name" do
    expect(subject[:region]).to eq(state.name)
  end

  context "in the US" do
    let(:country) { create(:country, iso: "US") }

    it "sets the region abbr" do
      expect(subject[:region]).to eq(state.abbr)
    end
  end
end
