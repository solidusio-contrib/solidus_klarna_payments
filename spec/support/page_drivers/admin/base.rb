module PageDrivers
  module Admin
    class Base < SitePrism::Page

      element :user_menu, '[data-hook="admin_login_navigation_bar"] .dropdown-toggle'

      if KlarnaGateway.is_spree? && !KlarnaGateway.up_to_spree?('3.0.99')
        element :logout_button, '[data-hook="user-logout-link"] a'
      else
        element :logout_button, '[data-hook="admin_login_navigation_bar"] ul#login-nav li[data-hook="user-logout-link"] a'
      end

      def scroll_to(element)
        script = <<-JS
          arguments[0].scrollIntoView(true);
        JS

        Capybara.current_session.driver.browser.execute_script(script, element.native)
        element
      end

      def logout
        user_menu.click rescue nil
        logout_button.click
      end
    end
  end
end

