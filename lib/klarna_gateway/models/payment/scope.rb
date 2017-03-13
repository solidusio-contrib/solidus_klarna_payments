module KlarnaGateway
  module Payment
    module Scope
      def self.included(base)
        base.class_eval do
          scope :klarna_credit, ->{ where(source_type: 'Spree::KlarnaCreditPayment') }
        end
      end
    end
  end
end
