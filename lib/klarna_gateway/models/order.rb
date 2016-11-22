module KlarnaGateway
  module Order
    KLARNA_SESSION_LIFETIME = 60.minutes

    def update_klarna_session(session_id: null, client_token: null)
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
  end
end
