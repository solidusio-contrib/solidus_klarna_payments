# frozen_string_literal: true

module Spree
  class KlarnaCreditPayment < PaymentSource
    belongs_to :payment_method
    belongs_to :user, class_name: Spree.user_class.to_s, optional: true
    belongs_to :order, class_name: 'Spree::Order', foreign_key: 'spree_order_id', optional: true

    serialize :response_body, Hash

    scope :with_payment_profile, -> { where(false) }

    def reusable?
      true
    end

    def imported
      false
    end

    def has_payment_profile?
      false
    end

    def actions
      %w(refresh capture cancel extend_period release credit)
    end

    def can_refresh?(_payment)
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

    # See the solidus_multi_capture gem
    def can_partial_capture?(payment)
      payment.pending? && (authorized? || part_captured?)
    end

    def accept!
      self.fraud_status = 'ACCEPTED'
      save
    end

    def reject!
      self.fraud_status = 'REJECTED'
      save
    end

    def accepted?
      fraud_status == 'ACCEPTED'
    end

    def pending?
      fraud_status == 'PENDING'
    end

    def rejected?
      fraud_status == 'REJECTED'
    end

    def error?
      error_code? && error_messages?
    end

    def fraud_status_icon
      case fraud_status
      when 'ACCEPTED'
        'ready'
      when 'PENDING'
        'pending'
      when 'REJECTED'
        'void'
      else
        'void' if error?
      end
    end

    def status_icon
      case status
      when 'AUTHORIZED', 'PART_CAPTURED', 'CAPTURED'
        'ready'
      else
        'void'
      end
    end

    def authorized?
      status.present? && status == 'AUTHORIZED'
    end

    def part_captured?
      status.present? && status == 'PART_CAPTURED'
    end

    def captured?
      status.present? && status.match('CAPTURED')
    end

    def fully_captured?
      status.present? && status == 'CAPTURED'
    end

    def cancelled?
      status.present? && status == 'CANCELLED'
    end

    def expired?
      status.present? && status == 'EXPIRED'
    end

    def closed?
      status.present? && status == 'CLOSED'
    end

    def expired?
      expires_at? && expires_at < DateTime.now
    end

    def payments
      Spree::Payment.where(source: self, payment_method: payment_method)
    end
  end
end
