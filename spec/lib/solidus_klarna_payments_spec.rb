# frozen_string_literal: true

require 'spec_helper'

describe SolidusKlarnaPayments do
  describe '.configure' do
    it 'yields an instance of the configuration' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(an_instance_of(SolidusKlarnaPayments::Configuration))
    end
  end

  describe '.configuration' do
    it 'returns the current configuration' do
      expect(described_class.configuration).to be_instance_of(SolidusKlarnaPayments::Configuration)
    end
  end
end
