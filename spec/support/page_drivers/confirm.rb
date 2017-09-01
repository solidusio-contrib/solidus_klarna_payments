module PageDrivers
  class CheckoutSteps < SitePrism::Section
    element :address, :xpath, 'li[1]'
    element :delivery, :xpath, 'li[2]'
    element :payment, :xpath, 'li[3]'
  end

  class Confirm < SitePrism::Page
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
      continue_button.click
    end
  end
end
