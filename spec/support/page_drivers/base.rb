module PageDrivers
  class Base < SitePrism::Page

    def scroll_to(element)
      script = <<-JS
        arguments[0].scrollIntoView(true);
      JS

      Capybara.current_session.driver.browser.execute_script(script, element.native)
      element
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
