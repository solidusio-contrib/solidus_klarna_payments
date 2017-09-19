module PageDrivers
  class Delivery < Base
    set_url "/checkout/delivery"

    element :continue_button, "form#checkout_form_delivery input.continue"
    elements :stock_contents, "table.stock-contents"

    def continue
      scroll_to(continue_button)
      continue_button.click
    end
  end
end

