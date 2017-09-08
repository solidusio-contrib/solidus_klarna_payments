require "spec_helper.rb"

describe KlarnaGateway::AddressSerializer do
  let(:serializer) { KlarnaGateway::AddressSerializer.new(address) }
  subject(:serialized) { serializer.to_hash }
  let(:address) { Spree::Address.new(state: state, country: country) }
  let(:country) { build(:country, iso: "DE") }
  let(:state) { build(:state) }

  # regression test
  it "sets the region name" do
    expect(subject[:region]).to eq(state.name)
  end

  context "in the US" do
    let(:country) { build(:country, iso: "US") }

    it "sets the region abbr" do
      expect(subject[:region]).to eq(state.abbr)
    end
  end
end
