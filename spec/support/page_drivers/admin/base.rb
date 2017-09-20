module PageDrivers
  module Admin
    class Base < SitePrism::Page

      def scroll_to(element)
        script = <<-JS
          arguments[0].scrollIntoView(true);
        JS

        Capybara.current_session.driver.browser.execute_script(script, element.native)
        element
      end
    end
  end
end

