# frozen_string_literal: true

require 'site_prism'

require 'support/page_drivers/base'
require 'support/page_drivers/home'
require 'support/page_drivers/address'
require 'support/page_drivers/cart'
require 'support/page_drivers/complete'
require 'support/page_drivers/confirm'
require 'support/page_drivers/delivery'
require 'support/page_drivers/payment'
require 'support/page_drivers/product'
require 'support/page_drivers/registration'

require 'support/page_drivers/admin/base'
require 'support/page_drivers/admin/order_menu'

require 'support/page_drivers/admin/login'
require 'support/page_drivers/admin/logs'
require 'support/page_drivers/admin/new_payment'
require 'support/page_drivers/admin/payment'
require 'support/page_drivers/admin/payments'
require 'support/page_drivers/admin/order'
require 'support/page_drivers/admin/orders'
require 'support/page_drivers/admin/customer'
require 'support/page_drivers/admin/promotion'
require 'support/page_drivers/admin/promotions'
require 'support/page_drivers/admin/new_promotion'
require 'support/page_drivers/admin/refunds'

module TestHelpers
  module SitePrismHelper
    def method_missing(m, *_args)
      if (matches = /on_the_(?<page>.*?)_page/.match(m))
        class_name = matches[:page]
        if (admin = /^admin/.match(matches[:page]))
          class_name = class_name.gsub("admin_", "admin/")
        end

        unless instance_variable_get("@#{matches[:page]}")
          instance_variable_set("@#{matches[:page]}", "page_drivers/#{class_name}".camelize.constantize.new)
        end

        if block_given?
          return yield instance_variable_get("@#{matches[:page]}")
        end

        instance_variable_get("@#{matches[:page]}")
      end
    end
  end
end

RSpec.configure do |config|
  config.include TestHelpers::SitePrismHelper, type: :feature
end
