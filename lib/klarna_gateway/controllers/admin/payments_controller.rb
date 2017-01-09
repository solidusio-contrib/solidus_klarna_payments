module KlarnaGateway
  module Admin
    module PaymentsController
      def self.included(base)
        base.before_action(:find_klarna_order, only: [:show])
      end

      private

      def find_klarna_order
        if @payment.is_valid_klarna?
          @klarna_order = @payment.klarna_order
        end
      end
    end
  end
end
