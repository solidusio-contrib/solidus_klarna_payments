# frozen_string_literal: true

module SolidusKlarnaPayments
  module Spree
    module Admin
      module PaymentsControllerDecorator
        def self.prepended(base)
          base.class_eval do
            before_action :find_klarna_order, only: :show
          end
        end

        private

        def find_klarna_order
          if @payment.is_valid_klarna?
            @klarna_order = @payment.klarna_order
          end
        end

        ::Spree::Admin::PaymentsController.prepend self
      end
    end
  end
end
