module KlarnaGateway
  # TODO: pull this out of the checkout controller
  module SessionController
    def self.included(base)
      base.skip_before_action(:ensure_valid_state, only: [:klarna_session, :order_status, :order_addresses, :klarna_update_session])
    end

    def klarna_session
      @order.state = "payment"

      if @order.klarna_session_expired?
        klarna_payment_method.provider.create_session(klarna_order(skip_personal_data: true).to_hash).tap do |response|
          @order.update_klarna_session(
            session_id: response.session_id,
            client_token: response.client_token
            ) if response.success?
        end
      else
        klarna_payment_method.provider.update_session(
          @order.klarna_session_id,
          klarna_order(skip_personal_data: true).to_hash
        ).tap do |response|
          @order.update_klarna_session_time() if response.success?
        end
      end

      render json: {token: @order.reload.klarna_client_token}
    end

    def order_status
      render json: {status: !@order.klarna_session_expired?, token: @order.klarna_client_token, data: klarna_order.to_hash}
    end

    def order_addresses
      addresses = {
        billing_address: KlarnaGateway::AddressSerializer.new(@order.billing_address).to_hash,
        shipping_address: KlarnaGateway::AddressSerializer.new(@order.shipping_address).to_hash
      }
      addresses.update(addresses) do |k,v|
        {email: @order.email}.merge(v)
      end
      render json: klarna_order.addresses
    end

    def klarna_update_session
      @order.klarna_payments.last.source.update_attributes({ authorization_token: params[:token] })
      render json: {status: "ok"}
    end

    private

    def klarna_order(skip_personal_data: false)
      order = @order.to_klarna(klarna_payment_method.options[:country])
      order.options = klarna_options
      order.skip_personal_data = skip_personal_data
      order.design = klarna_payment_method.options[:design]
      order.store = current_store
      order
    end

    def klarna_payment_method
      @klarna_payment_method ||= Spree::PaymentMethod.find_by(id: klarna_payment_method_id, type: 'Spree::Gateway::KlarnaCredit')
    end

    def klarna_options
      klarna_payment_method.options.select do |key, value|
        key.to_s.start_with?("color_", "radius_") && value.present?
      end
    end

    def klarna_payment_method_id
      params[:klarna_payment_method_id] || @order.payments.where(source_type: 'Spree::KlarnaCreditPayment').last.payment_method_id
    end
  end
end
