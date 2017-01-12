module PageDrivers
  class Home < Base

    def choose(name)
      click_link name
    end
  end
end
