module Admin
  class PaymentSection < SitePrism::Section
    element :capture_button, "[data-action='capture']"
    element :klarna_captured, ".state.ready", text: "CAPTURED"

    def capture
      capture_button.click
    end

    def captured?
      has_klarna_captured?
    end
  end

  class OrderPaymentsPage < SitePrism::Page
    set_url "/admin/orders/{number}/payments"

    sections :payments, Admin::PaymentSection, "#payments tr.payment"
    
    section :order_information, Admin::OrderInformation, "#order_tab_summary"
  end
end
