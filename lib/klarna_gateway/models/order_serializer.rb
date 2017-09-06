module KlarnaGateway
  class OrderSerializer
    attr_reader :order, :region
    attr_accessor :options, :design, :skip_personal_data, :store

    def initialize(order, region = :us)
      @order = order
      @region = region.downcase.to_sym
      @options = {}
    end

    def to_hash
      strategy.adjust_with(order) do
        config
      end
    end

    def addresses
      {
        billing_address: billing_address,
        shipping_address: shipping_address
      }
    end

    def shipping_info
      @order.shipments.map do |shipment|
        {
          shipping_company: shipment.shipping_method.name,
          tracking_number: shipment.tracking,
          tracking_uri: shipment.tracking_url,
        }
      end
    end

    private

    def config
      {
        purchase_country: purchase_country,
        purchase_currency: order.currency,
        locale: strategy.locale(region),
        # amount with taxes and adjustments
        order_amount: order.display_total.cents,
        billing_address: billing_address,
        shipping_address: shipping_address,
        order_lines: order_lines,
        merchant_reference1: order.number,
        options: options,
        design: design,
        merchant_urls: merchant_urls,
      }.delete_if { |k, v| v.nil? }
    end

    def purchase_country
      order.billing_address.try(:country).try(:iso) ||
        order.shipping_address.try(:country).try(:iso) ||
        region
    end

    def order_lines
      line_items + shipments
    end

    def line_items
      order.line_items.map do |line_item|
        LineItemSerializer.new(line_item, strategy.line_item_strategy).to_hash
      end
    end

    def shipments
      order.shipments.map do |shipment|
        ShipmentSerializer.new(shipment, strategy.shipment_strategy).to_hash
      end
    end

    def billing_address
      return shipping_address if order.billing_address.nil?
      {
        email: @order.email
      }.merge(
        AddressSerializer.new(order.billing_address).to_hash
      )
    end

    def shipping_address
      return nil if order.shipping_address.nil?
      {
        email: @order.email
      }.merge(
        AddressSerializer.new(order.shipping_address).to_hash
      )
    end

    def strategy
      @strategy ||= case region
        when :us then KlarnaGateway::AmountCalculators::US::OrderCalculator.new
        else KlarnaGateway::AmountCalculators::UK::OrderCalculator.new(skip_personal_data)
        end
    end

    def merchant_urls
      {
        # terms: "http://host/terms",
        # checkout: "http://host/orders/#{@order.number}",
        # push: "http://host/klarna/push",
        # validation: "string",
        # shipping_option_update: "string",
        # address_update: "string",
        # country_change: "string",
        confirmation: confirmation_url,
        notification: url_helpers.klarna_notification_url(host: store_url)
      } if store.present?
    end

    def confirmation_url
      configured_url = KlarnaGateway.configuration.confirmation_url
      case configured_url
      when String then configured_url
      when Proc then configured_url.call(store, @order)
      else url_helpers.order_url(@order.number, host: store_url)
      end
    end

    def store_url
      store.url.to_s.split("\n").first.chomp
    end

    def url_helpers
      Spree::Core::Engine.routes.url_helpers
    end
  end
end
