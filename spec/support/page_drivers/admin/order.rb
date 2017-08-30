module PageDrivers
  module Admin
    class Order < Base
      set_url '/admin/orders/{number}/edit'

      if KlarnaGateway.is_solidus?
        section :menu, PageDrivers::Admin::OrderMenu, '.container nav ul.tabs'
      else
        section :menu, PageDrivers::Admin::OrderMenu, 'aside#sidebar nav.menu ul'
      end
    end
  end
end

