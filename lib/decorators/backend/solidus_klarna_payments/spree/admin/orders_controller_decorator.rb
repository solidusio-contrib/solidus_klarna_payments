# frozen_string_literal: true

module SolidusKlarnaPayments
  module Spree
    module Admin
      module OrdersControllerDecorator
        def self.prepended(base)
          base.class_eval do
            rescue_from ::Spree::Core::GatewayError do |exception|
              flash[:error] = exception.message
              redirect_to(spree.admin_order_payments_path(@order))
            end
          end
        end

        ::Spree::Admin::OrdersController.prepend self
      end
    end
  end
end
