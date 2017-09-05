module PageDrivers
  class Home < Base
    set_url "/"
    elements :products, '[data-hook="homepage_products"] ul#products li'


    def choose(name)
      products.find{|e| e.text.match(name)}.click
    end

    def update_hosts
      if KlarnaGateway.up_to_solidus?('1.5.0')
        Spree::Store.current.update_attributes(url: "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}")
      else
        Spree::Store.default.update_attributes(url: "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}")
      end
    end
  end
end
