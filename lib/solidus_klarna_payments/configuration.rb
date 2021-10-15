# frozen_string_literal: true

module SolidusKlarnaPayments
  class Configuration
    attr_accessor :confirmation_url, :image_host, :product_url
    attr_writer :retrieve_customer_token_service_class

    def retrieve_customer_token_service_class
      @retrieve_customer_token_service_class ||= 'SolidusKlarnaPayments::RetrieveCustomerTokenService'
      @retrieve_customer_token_service_class.constantize
    end
  end
end
