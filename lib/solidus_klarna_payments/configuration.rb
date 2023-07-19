# frozen_string_literal: true

module SolidusKlarnaPayments
  class Configuration
    attr_accessor :confirmation_url, :image_host, :product_url
    attr_writer :store_customer_token_service_class, :retrieve_customer_token_service_class

    def store_customer_token_service_class
      @store_customer_token_service_class ||= 'SolidusKlarnaPayments::StoreCustomerTokenService'
      @store_customer_token_service_class.constantize
    end

    def retrieve_customer_token_service_class
      @retrieve_customer_token_service_class ||= 'SolidusKlarnaPayments::RetrieveCustomerTokenService'
      @retrieve_customer_token_service_class.constantize
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def configure
      yield configuration
    end
  end
end
