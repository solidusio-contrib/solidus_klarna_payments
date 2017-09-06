module Spree
  module Klarna
    class CallbacksController < Spree::StoreController
      include KlarnaGateway::NotificationsController

      skip_before_action :verify_authenticity_token
    end
  end
end
