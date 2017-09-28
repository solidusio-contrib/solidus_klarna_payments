module PageDrivers
  class Delivery < Base
    set_url "/checkout/delivery"

    if KlarnaGateway.is_spree? && !KlarnaGateway.up_to_spree?('2.4.99')
      element :continue_button, 'form#checkout_form_delivery input.btn'
    else
      element :continue_button, 'form#checkout_form_delivery input.continue'
    end
    elements :stock_contents, "table.stock-contents"

    def continue
      scroll_to(continue_button)
      continue_button.click
    end
  end
end

