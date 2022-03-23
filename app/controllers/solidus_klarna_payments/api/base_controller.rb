# frozen_string_literal: true

module SolidusKlarnaPayments
  module Api
    class BaseController < ::Spree::StoreController
      skip_before_action :verify_authenticity_token
    end
  end
end
