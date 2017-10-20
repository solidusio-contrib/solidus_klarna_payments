module KlarnaGateway
  module Admin
    module PaymentMethodsController
      def self.included(base)
        base.prepend_before_action(:validate_klarna_credentials, only: [:update])
      end

      private

      def validate_klarna_credentials
        if params[:payment_method][:type] == 'Spree::Gateway::KlarnaCredit'
          if (params[:gateway_klarna_credit][:preferred_api_secret].blank? || params[:gateway_klarna_credit][:preferred_api_key].blank?)
            flash[:error] = Spree.t('klarna.can_not_test_api_connection')
          end

          if params[:gateway_klarna_credit][:preferred_api_secret].present? && params[:gateway_klarna_credit][:preferred_api_key].present?
            Klarna.configure do |config|
              config.environment = !Rails.env.production? ? 'test' : 'production'
              config.country = params[:gateway_klarna_credit][:preferred_country]
              config.api_key =  params[:gateway_klarna_credit][:preferred_api_key]
              config.api_secret = params[:gateway_klarna_credit][:preferred_api_secret]
              config.user_agent = "Klarna Spree Gateway/#{::KlarnaGateway::VERSION} Spree/#{::Spree.version} Rails/#{::Rails.version}"
            end

            klarna_response = Klarna.client(:credit).create_session({})

            if klarna_response.code == 401
              flash[:error] = Spree.t('klarna.invalid_api_credentials')
            else
              flash[:notice] = Spree.t('klarna.valid_api_credentials')
            end
          end
        end
      end
    end
  end
end
