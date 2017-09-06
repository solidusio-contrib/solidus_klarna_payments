module KlarnaGateway
  module Refund
    def self.included(base)
      base.send(:after_create, :log_entries_in_payment)
    end

    private

    def log_entries_in_payment
      payment.send(:record_response, @response) if payment.is_klarna?
    end
  end
end
