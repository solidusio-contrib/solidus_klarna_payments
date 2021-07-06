# frozen_string_literal: true

module SolidusKlarnaPayments
  module Spree
    module Admin
      module PaymentMethodsControllerDecorator
        def update
          validate_klarna_credentials
          super
        end

        private

        def validate_klarna_credentials
          if params[:payment_method][:type] == 'Spree::PaymentMethod::KlarnaCredit'
            if params[:payment_method][:preferred_api_secret].blank? || params[:payment_method][:preferred_api_key].blank?
              flash[:error] = I18n.t('spree.klarna.can_not_test_api_connection')
            end

            if params[:payment_method][:preferred_api_secret].present? && params[:payment_method][:preferred_api_key].present?
              Klarna.configure do |config|
                config.environment = !Rails.env.production? ? 'test' : 'production'
                config.country = params[:payment_method][:preferred_country]
                config.api_key =  params[:payment_method][:preferred_api_key]
                config.api_secret = params[:payment_method][:preferred_api_secret]
                config.user_agent = "Klarna Solidus Gateway/#{::SolidusKlarnaPayments::VERSION} Solidus/#{::Spree.solidus_version} Rails/#{::Rails.version}"
              end

              klarna_response = Klarna.client(:credit).create_session({})

              if klarna_response.http_response.code == '401'
                flash[:error] = I18n.t('spree.klarna.invalid_api_credentials')
              else
                flash[:notice] = I18n.t('spree.klarna.valid_api_credentials')
              end
            end
          end
        end

        ::Spree::Admin::PaymentMethodsController.prepend self
      end
    end
  end
end
