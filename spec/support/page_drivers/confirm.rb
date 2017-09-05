module PageDrivers
  class CheckoutSteps < SitePrism::Section
    element :address, :xpath, 'li[1]'
    element :delivery, :xpath, 'li[2]'
    element :payment, :xpath, 'li[3]'
  end

  class Confirm < Base
    set_url "/checkout/confirm"

    section :checkout_steps, CheckoutSteps, 'ol#checkout-step-confirm'
    element :item_price, 'td[data-hook="order_item_price"]'
    element :item_quantity, 'td[data-hook="order_item_qty"]'
    element :item_total, 'td[data-hook="order_item_total"]'
    element :continue_button, "form#checkout_form_confirm input.continue"

    def change_payment
      checkout_steps.payment.click
    end

    def quantity_of_items_in_cart
      item_quantity.text.to_i
    end

    def item_total_price
      item_total.text[1..-1]
    end

    def continue
      scroll_to(continue_button)
      if KlarnaGateway.up_to_solidus?('1.5.0')
        Spree::Store.current.update_attributes(url: "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}")
      else
        Spree::Store.default.update_attributes(url: "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}")
      end

      continue_button.click
    end
  end
end
