module KlarnaGateway
  module Order
    KLARNA_SESSION_LIFETIME = 48.hours

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
      KlarnaGateway::OrderSerializer.new(self.reload, country)
    end

    def has_klarna_payments?
      payments.where(source_type: 'Spree::KlarnaCreditPayment').any?
    end

    def authorized_klarna_payments
      payments.where(source_type: 'Spree::KlarnaCreditPayment').find_all do |payment|
        payment.source.authorized?
      end
    end

    def captured_klarna_payments
      payments.where(source_type: 'Spree::KlarnaCreditPayment').find_all do |payment|
        payment.source.captured?
      end
    end

    def can_be_cancelled_from_klarna?
      payments.where(source_type: 'Spree::KlarnaCreditPayment').find_all do |payment|
        !payment.source.cancelled?
      end.none?
    end

    private

    def klarna_payment_provider
      payments.where(source_type: 'Spree::KlarnaCreditPayment').last.payment_method.provider
    end
  end
end
