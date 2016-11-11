module Spree
  class KlarnaCreditPayment < Spree::Base
    belongs_to :payment_method
    belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id'

    def imported
      false
    end

    def brand
      :klarna_credit
    end

    def has_payment_profile?
      false
    end

    def actions
      %w(capture)
    end

    def can_capture?(payment)
      payment.pending?
    end

    def accepted?
      self.fraud_status == "ACCEPTED"
    end

    def pending?
      self.fraud_status == "PENDING"
    end
  end
end
