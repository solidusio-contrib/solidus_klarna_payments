module KlarnaGateway
  module Order
    KLARNA_SESSION_LIFETIME = 60.minutes

    def update_klarna_session(session_id: nil, client_token: nil)
      self.update_attributes(
        klarna_session_id: session_id,
        klarna_client_token: client_token,
        klarna_session_expires_at: DateTime.now + KLARNA_SESSION_LIFETIME
      )
    end

    def update_klarna_session_time
      self.update_attributes(
        klarna_session_expires_at: DateTime.now + KLARNA_SESSION_LIFETIME
      )
    end

    def klarna_session_expired?
      !(self.klarna_session_expires_at.present? && self.klarna_session_expires_at >= DateTime.now)
    end

    def to_klarna(country=:us)
      Spree::OrderSerializer.new(self.reload, country)
    end

    def klarna_order
      response = klarna_payment_provider.get(self.klarna_order_id)
      if response.success?
        response.body
      end
    end

    def klarna_approve!
      klarna_payment_provider.acknowledge(self.klarna_order_id)
    end

    def klarna_extend!
      klarna_payment_provider.extend(self.klarna_order_id)
    end

    def klarna_release!
      klarna_payment_provider.release(self.klarna_order_id)
    end

    private

    def klarna_payment_provider
      payments.where(source_type: 'Spree::KlarnaCreditPayment').last.payment_method.provider
    end
  end
end
