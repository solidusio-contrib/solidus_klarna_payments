module KlarnaGateway
  module Admin
    module OrdersController
      def self.included(base)
        base.rescue_from 'Spree::Core::GatewayError' do |exception|
          flash[:error] = exception.message
          redirect_to(spree.admin_order_payments_path(@order))
        end
      end
    end
  end
end
