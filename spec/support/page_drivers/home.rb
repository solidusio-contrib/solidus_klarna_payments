module PageDrivers
  class Home < Base
    set_url "/"
    elements :products, '[data-hook="homepage_products"] ul#products li'


    def choose(name)
      products.find{|e| e.text.match(name)}.click
    end
  end
end
