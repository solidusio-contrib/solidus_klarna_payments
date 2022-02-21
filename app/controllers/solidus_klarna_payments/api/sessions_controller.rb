# frozen_string_literal: true

module SolidusKlarnaPayments
  module Api
    class SessionsController < ::Spree::BaseController
      include ::Spree::Core::ControllerHelpers::Order

      def create
        render json: {
          token: SolidusKlarnaPayments::CreateOrUpdateKlarnaSessionService.call(
            order: current_order,
            klarna_payment_method: klarna_payment_method,
            store: current_store
          )
        }
      end

      def show
        render json: {
          status: !current_order.klarna_session_expired?,
          token: current_order.klarna_client_token,
          data: klarna_order.to_hash,
        }
      end

      def order_addresses
        addresses = {
          billing_address: SolidusKlarnaPayments::AddressSerializer.new(current_order.billing_address).to_hash,
          shipping_address: SolidusKlarnaPayments::AddressSerializer.new(current_order.shipping_address).to_hash
        }

        addresses.update(addresses) do |_k, v|
          { email: current_order.email }.merge(v)
        end

        render json: klarna_order.serialized_order.addresses
      end

      private

      def klarna_order
        SolidusKlarnaPayments::CreateSessionOrderPresenter.new(
          order: current_order,
          klarna_payment_method: klarna_payment_method,
          store: current_store,
          skip_personal_data: false
        )
      end

      def klarna_payment_method
        @klarna_payment_method ||= ::Spree::PaymentMethod.find_by(id: klarna_payment_method_id, type: 'Spree::PaymentMethod::KlarnaCredit')
      end

      def klarna_payment_method_id
        params[:klarna_payment_method_id] || current_order.payments.where(source_type: 'Spree::KlarnaCreditPayment').last.payment_method_id
      end
    end
  end
end
