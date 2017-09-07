module PageDrivers
  module Admin
    class Order < SitePrism::Page
      set_url '/admin/orders/{number}/edit'

      section :menu, PageDrivers::Admin::OrderMenu, '.container nav ul.tabs'
    end
  end
end

