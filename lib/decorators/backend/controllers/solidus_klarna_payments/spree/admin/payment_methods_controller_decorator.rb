# frozen_string_literal: true

module SolidusKlarnaPayments
  module Spree
    module Admin
      module PaymentMethodsControllerDecorator
        def update
          validate_api_credentials if klarna_payment_method?

          super
        end

        private

        def klarna_payment_method_params
          params
            .require(:payment_method)
            .permit(
              :preferred_api_key,
              :preferred_api_secret,
              :preferred_test_mode,
              :preferred_country
            )
        end

        def klarna_payment_method?
          payment_method_params[:type] == 'Spree::PaymentMethod::KlarnaCredit'
        end

        def validate_api_credentials
          result = ::SolidusKlarnaPayments::ValidateKlarnaCredentialsService.call(
            api_key: klarna_payment_method_params[:preferred_api_key],
            api_secret: klarna_payment_method_params[:preferred_api_secret],
            test_mode: klarna_payment_method_params[:preferred_test_mode],
            country: klarna_payment_method_params[:preferred_country]
          )

          if result
            flash[:notice] = I18n.t('spree.klarna.valid_api_credentials')
          else
            flash[:error] = I18n.t('spree.klarna.invalid_api_credentials')
          end
        rescue ::SolidusKlarnaPayments::ValidateKlarnaCredentialsService::MissingCredentialsError
          flash[:error] = I18n.t('spree.klarna.can_not_test_api_connection')
        end

        ::Spree::Admin::PaymentMethodsController.prepend self
      end
    end
  end
end
