# frozen_string_literal: true

module SolidusKlarnaPayments
  module Spree
    module RefundDecorator
      def self.prepended(base)
        base.class_eval do
          after_create :log_entries_in_payment
        end
      end

      private

      def log_entries_in_payment
        payment.send(:record_response, @response) if payment.is_klarna?
      end

      ::Spree::Refund.prepend self
    end
  end
end
