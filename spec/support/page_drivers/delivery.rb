module PageDrivers
  class Delivery < SitePrism::Page
    set_url "/checkout/delivery"

    element :continue_button, "form#checkout_form_delivery input.continue"
    elements :stock_contents, "table.stock-contents"

    def continue
      continue_button.click
    end
  end
end

