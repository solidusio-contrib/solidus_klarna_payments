module Spree
  module Klarna
    class SessionsController < StoreController
      include ::KlarnaGateway::SessionController
    end
  end
end
