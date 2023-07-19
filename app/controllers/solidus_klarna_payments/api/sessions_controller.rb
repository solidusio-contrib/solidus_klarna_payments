# frozen_string_literal: true

module SolidusKlarnaPayments
  module Api
    class SessionsController < ::Spree::Api::BaseController
      def create
        render json: {
          token: SolidusKlarnaPayments::CreateOrUpdateKlarnaSessionService.call(
            order: @order,
            klarna_payment_method: klarna_payment_method,
            store: current_store
          )
        }
      end

      def show
        render json: {
          status: !@order.klarna_session_expired?,
          token: @order.klarna_client_token,
          data: klarna_order.to_hash,
        }
      end

      def order_addresses
        addresses = {
          billing_address: SolidusKlarnaPayments::AddressSerializer.new(@order.billing_address).to_hash,
          shipping_address: SolidusKlarnaPayments::AddressSerializer.new(@order.shipping_address).to_hash
        }

        addresses.update(addresses) do |_k, v|
          { email: @order.email }.merge(v)
        end

        render json: klarna_order.serialized_order.addresses
      end

      private

      def klarna_order
        SolidusKlarnaPayments::CreateSessionOrderPresenter.new(
          order: @order,
          klarna_payment_method: klarna_payment_method,
          store: current_store,
          skip_personal_data: false
        )
      end

      def klarna_payment_method
        @klarna_payment_method ||= ::Spree::PaymentMethod.find_by(id: klarna_payment_method_id,
          type: 'Spree::PaymentMethod::KlarnaCredit')
      end

      def klarna_payment_method_id
        params[:klarna_payment_method_id] || @order.payments.where(source_type: 'Spree::KlarnaCreditPayment').last.payment_method_id
      end
    end
  end
end
