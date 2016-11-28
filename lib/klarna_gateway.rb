require "spree_core"
require "spree_frontend"

require "klarna_gateway/engine"
require "klarna_gateway/version"

require "active_merchant/billing/gateways/klarna_gateway"

require "klarna_gateway/models/order"
require "klarna_gateway/controllers/session_controller"
require "klarna_gateway/controllers/admin/orders_controller"
