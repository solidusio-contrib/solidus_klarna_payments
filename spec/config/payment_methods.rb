
RSpec.configure do |config|
  if config.inclusion_filter.rules.has_key?(:bdd)
    config.before(:suite) do |example|
      raise "Please specify KLARNA_API_KEY=xyz KLARNA_API_SECRET=XYZ in your environment variables." if !ENV['KLARNA_API_KEY'].present? || !ENV['KLARNA_API_SECRET'].present?

      if Spree::PaymentMethod.where(type: 'Spree::Gateway::KlarnaCredit').none?
        Spree::PaymentMethod.create(
          name: "Klarna Credit",
          type: 'Spree::Gateway::KlarnaCredit',
          preferences: {
            server: "test",
            test_mode: true,
            api_key: ENV['KLARNA_API_KEY'],
            api_secret: ENV['KLARNA_API_SECRET'],
            country: "us"
          })
        Spree::PaymentMethod.create(
          name: "Wrong Klarna",
          type: 'Spree::Gateway::KlarnaCredit',
          preferences: {
            server: "test",
            test_mode: true,
            api_key: 'wrong_key',
            api_secret: ENV['KLARNA_API_SECRET'],
            country: "us"
          })
      end
    end
  end
end
