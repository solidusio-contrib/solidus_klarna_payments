module KlarnaGateway
  module Payment
    module Scope
      def self.included(base)
        base.class_eval do
          scope :klarna_credit, ->{ where(source_type: 'Spree::KlarnaCreditPayment') }
          scope :risky, -> do
            joins("JOIN spree_klarna_credit_payments ON spree_payments.source_id = spree_klarna_credit_payments.id")
              .where("avs_response IN (?) OR (cvv_response_code IS NOT NULL and cvv_response_code != 'M') OR state = 'failed' OR (fraud_status = 'REJECTED' AND source_type = 'Spree::KlarnaCreditPayment')", Spree::Payment::RISKY_AVS_CODES)
          end

          scope :klarna_risky, -> do
            joins("JOIN spree_klarna_credit_payments ON spree_payments.source_id = spree_klarna_credit_payments.id")
              .where("fraud_status = 'REJECTED' AND source_type = 'Spree::KlarnaCreditPayment'")
          end
        end
      end
    end
  end
end
