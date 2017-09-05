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

      element :logout_button, '[data-hook="admin_login_navigation_bar"] ul#login-nav li[data-hook="user-logout-link"] a'
    end
  end
end

