module Spree
  class KlarnaCreditPayment < Spree::Base
    belongs_to :payment_method
    belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id'
    belongs_to :order, class_name: Spree::Order, foreign_key: 'spree_order_id'
    serialize :response_body, Hash

    scope :with_payment_profile, -> { where(false) }

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
      %w(refresh capture cancel extend_period release credit)
    end

    def can_refresh?(payment)
      true
    end

    def can_extend_period?(payment)
      payment.pending? && authorized? && !expired?
    end

    def can_capture?(payment)
      payment.pending? && authorized?
    end

    def can_cancel?(payment)
      payment.pending? && authorized?
    end

    def can_release?(payment)
      payment.completed? && part_captured?
    end

    def can_credit?(payment)
      payment.completed? && captured? && !part_captured?
    end

    def accept!
      self.fraud_status = "ACCEPTED"
      save
    end

    def reject!
      self.fraud_status = "REJECTED"
      save
    end

    def accepted?
      self.fraud_status == "ACCEPTED"
    end

    def pending?
      self.fraud_status == "PENDING"
    end

    def rejected?
      self.fraud_status == "REJECTED"
    end

    def error?
      self.error_code? && self.error_messages?
    end

    def fraud_status_icon
      case self.fraud_status
        when "ACCEPTED"
          'ready'
        when "PENDING"
          'pending'
        when "REJECTED"
          'void'
        else
          'void' if error?
      end
    end

    def status_icon
      case self.status
        when "AUTHORIZED"
        when "PART_CAPTURED"
        when "CAPTURED"
          'ready'
        else
          'void'
      end
    end

    def authorized?
      self.status.present? && self.status == "AUTHORIZED"
    end

    def part_captured?
      self.status.present? && self.status == "PART_CAPTURED"
    end

    def captured?
      self.status.present? && self.status.match("CAPTURED")
    end

    def fully_captured?
      self.status.present? && self.status == "CAPTURED"
    end

    def cancelled?
      self.status.present? && self.status == "CANCELLED"
    end

    def expired?
      self.status.present? && self.status == "EXPIRED"
    end

    def closed?
      self.status.present? && self.status == "CLOSED"
    end

    def expired?
      self.expires_at? && self.expires_at < DateTime.now
    end

    def payments
      Spree::Payment.where(source: self, payment_method: self.payment_method)
    end
  end
end
