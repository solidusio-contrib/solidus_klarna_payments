# frozen_string_literal: true

module PageDrivers
  module Admin
    class Base < SitePrism::Page
      element :user_menu, '[data-hook="admin_login_navigation_bar"] .dropdown-toggle'
      element :logout_button, '[data-hook="admin_login_navigation_bar"] ul#login-nav li[data-hook="user-logout-link"] a'

      def logout
        begin
          user_menu.click
        rescue StandardError
          nil
        end
        logout_button.click
      end
    end
  end
end
