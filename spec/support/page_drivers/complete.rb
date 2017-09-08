module PageDrivers
  class Complete < SitePrism::Page
    set_url "/orders{/order_number}"

    element :flash_message, '#content .flash'
    element :success_notice, '#content .flash.notice'
    element :order_number, 'fieldset#order_summary h1'

    def get_order_number
      order_number.text.gsub("Order|Bestellnummer ", "")
    end
  end
end
