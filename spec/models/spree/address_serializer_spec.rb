require "spec_helper.rb"

describe Spree::AddressSerializer do
  let(:serializer) { Spree::AddressSerializer.new(address) }
  subject(:serialized) { serializer.to_hash }
  let(:address) { Spree::Address.new(state: state, country: build(:country)) }
  let(:state) { build(:state) }

  # regression test
  it "sets the region name" do
    expect(subject[:region]).to eq(state.name)
  end
end
