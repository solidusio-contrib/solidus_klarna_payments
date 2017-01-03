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
