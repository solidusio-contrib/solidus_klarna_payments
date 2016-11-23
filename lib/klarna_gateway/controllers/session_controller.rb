module KlarnaGateway
  module SessionController
    def self.included(base)
      # TODO: only on klarna_session (maybe even not there)
      base.skip_action_callback(:ensure_valid_state)
    end

    def klarna_session
      @order.state = "payment"

      if @order.klarna_session_expired?
        klarna_payment_method.provider.create_session(klarna_order).tap do |response|
          @order.update_klarna_session(
            session_id: response.session_id,
            client_token: response.client_token
            ) if response.success?
        end
      else
        klarna_payment_method.provider.update_session(@order.klarna_session_id, klarna_order).tap do |response|
          @order.update_klarna_session_time() if response.success?
        end
      end

      render json: {token: @order.reload.klarna_client_token}
    end

    def klarna_reauthorize
      render json: {status: !@order.klarna_session_expired?, token: @order.klarna_client_token, data: klarna_order}
    end

    private

    def klarna_order
      order = @order.to_klarna(klarna_payment_method.preferences[:country])
      order.options = klarna_options
      order.design = klarna_payment_method.preferences[:design]
      order.to_hash
    end

    # TODO: hand over the payment method id in case there's more than one Klarna Credit
    def klarna_payment_method
      @klarna_payment_method ||= Spree::PaymentMethod.where(type: 'Spree::Gateway::KlarnaCredit').last
    end

    def klarna_options
      klarna_payment_method.preferences.select do |key, value|
        key.to_s.start_with?("color_", "radius_") && value.present?
      end
    end
  end
end
