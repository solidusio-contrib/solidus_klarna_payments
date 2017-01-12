module PageDrivers
  module CheckoutProcess

    def on_the_home_page
      @home ||= Home.new(page)
    end

    def on_the_product_page
      @product ||= Product.new(page)
    end

    def on_the_cart_page
      @cart ||= Cart.new(page)
    end

    def on_the_registration_page
      @registration ||= Registration.new(page)
    end

    def on_the_address_page
      @address ||= Address.new(page)
    end

    def on_the_delivery_page
      @delivery ||= Delivery.new(page)
    end

    def on_the_payment_page
      @payment ||= Payment.new(page)
    end

    def on_the_confirm_page
      @confirm ||= Confirm.new(page)
    end

    def on_the_complete_page
      @complete ||= Complete.new(page)
    end

  end
end
