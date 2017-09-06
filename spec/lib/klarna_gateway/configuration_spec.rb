require 'spec_helper'

describe "KlarnaGateway.configuration" do
  it 'it rais an exception when is not initialized' do
    expect(KlarnaGateway).to receive(:_configuration).and_return(nil)
    expect{KlarnaGateway.configuration}.to raise_error(KlarnaGateway::ConfigurationMissing)
  end

  it 'shows default nil value for confirmation_url' do
    expect(KlarnaGateway).to receive(:_configuration).at_least(:once).and_return(KlarnaGateway::Configuration.new)
    expect(KlarnaGateway.configuration.confirmation_url).to be_nil
  end
end


describe "KlarnaGateway solidus and spree version comparison" do
  it 'tests the actual framework' do
    expect(Spree).to receive(:respond_to?).with(:solidus_version).and_return(true)
    expect(KlarnaGateway.is_solidus?).to eq(true)

    expect(Spree).to receive(:respond_to?).with(:solidus_version).and_return(false)
    expect(KlarnaGateway.is_spree?).to eq(true)
  end

  it 'compares version on solidus' do
    expect(Spree).to receive(:solidus_version).at_least(:once).and_return('1.2.1')

    expect(KlarnaGateway.up_to_solidus?('1.0')).to eq(false)
    expect(KlarnaGateway.up_to_solidus?('1.2.1')).to eq(true)
    expect(KlarnaGateway.up_to_solidus?('1.2.2')).to eq(true)
  end

  it 'compares version on spree' do
    expect(Spree).to receive(:version).at_least(:once).and_return('1.2.1')
    expect(Spree).to receive(:respond_to?).with(:solidus_version).at_least(:once).and_return(false)

    expect(KlarnaGateway.up_to_spree?('1.0')).to eq(false)
    expect(KlarnaGateway.up_to_spree?('1.2.1')).to eq(true)
    expect(KlarnaGateway.up_to_spree?('1.2.2')).to eq(true)
  end
end
