# frozen_string_literal: true

SolidusKlarnaPayments.configure do |config|
  ## Generate the completion route dynamically
  #
  # Expected:
  #
  # config.confirmation_url = <String>
  # config.confirmation_url = <Proc>
  #
  # Examples:
  #
  # config.confirmation_url = helpers.path_to_order
  # config.confirmation_url = ->(store, order) { url_helpers.order_url(order.number, host: store.url) }

  ## Configure the image host.
  #
  # It is used to generate urls the pictures of products. Klarna can display these in invoices etc.
  #
  # When providing a proc, the first and only argument is the Spree::LineItem for which the product
  # image should be provided.
  #
  # Default is to use Rails' asset_host.
  #
  # Expected:
  #
  # config.image_host = nil (disable images)
  # config.image_host = <String>
  # config.image_host = <Proc>
  #
  # Example/default:
  #
  config.image_host = ActionController::Base.asset_host

  ## Configure the product url
  #
  # A Proc to generate a link to products. It receives a Spree::LineItem and should return the
  # url (not path) to the product as a string.
  #
  # If for some reason it's not possible to generate the URL from a line item, set this value to nil
  # to disable this feature. Klarna uses the URL to link to the purchased products.
  #
  # The default implementation will use the site's default store and should suffice for most sites.
  #
  # Expected:
  #
  # config.product_url = nil
  # config.product_url = <Proc>
  #
  # Example/default:
  #
  config.product_url = proc do |item|
    host = Spree::Store.default.url.lines.first
    Spree::Core::Engine.routes.url_helpers.product_url(item.variant, host: host) if host.present?
  end
end
