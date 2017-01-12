module PageDrivers
  class Confirm < Base

    def continue
      click_button 'Place Order'
    end
  end
end
