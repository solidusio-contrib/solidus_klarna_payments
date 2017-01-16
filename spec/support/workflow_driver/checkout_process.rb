module WorkflowDriver
  module CheckoutProcess

    def on_the_home_page
      @home ||= PageDrivers::Home.new(page)
    end

    def on_the_product_page
      @product ||= PageDrivers::Product.new(page)
    end

    def on_the_cart_page
      @cart ||= PageDrivers::Cart.new(page)
    end

    def on_the_registration_page
      @registration ||= PageDrivers::Registration.new(page)
    end

    def on_the_address_page
      @address ||= PageDrivers::Address.new(page)
    end

    def on_the_delivery_page
      @delivery ||= PageDrivers::Delivery.new(page)
    end

    def on_the_payment_page
      @payment ||= PageDrivers::Payment.new(page)
    end

    def on_the_confirm_page
      @confirm ||= PageDrivers::Confirm.new(page)
    end

    def on_the_complete_page
      @complete ||= PageDrivers::Complete.new(page)
    end

  end
end
