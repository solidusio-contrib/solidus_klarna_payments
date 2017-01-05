module Spree
  class KlarnaController < Spree::StoreController
    skip_before_action :verify_authenticity_token

    include KlarnaGateway::NotificationsController

  end
end
