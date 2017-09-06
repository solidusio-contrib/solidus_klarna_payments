module Admin
  class OrderInformation < SitePrism::Section
    element :order_status, "#order_status + dd .state"
    
    def completed?
      order_status.text == "complete"
    end
  end

  class OrderPage < SitePrism::Page
    set_url "/admin/orders/{number}/edit"
  end
end
