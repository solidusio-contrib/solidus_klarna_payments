# frozen_string_literal: true

SolidusKlarnaPayments.configure do |config|
  # config.confirmation_url = ->(_store, _order) { "http://example.com/thank-you" }
  # config.image_host = ->(_line_item) { "http://images.example.com" }
  # config.product_url = ->(line_item) { "http://example.com/product/#{line_item.variant.id}" }

  # config.store_customer_token_service_class = 'SolidusKlarnaPayments::StoreCustomerTokenService'
  # config.retrieve_customer_token_service_class = 'SolidusKlarnaPayments::RetrieveCustomerTokenService'
end
