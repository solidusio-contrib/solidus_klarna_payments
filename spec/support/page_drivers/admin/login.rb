module PageDrivers
  module Admin
    class Login < SitePrism::Page
      set_url '/admin/login'

      element :title, '#existing-customer h6'
      element :email, 'form #spree_user_email'
      element :password, 'form #spree_user_password'
      element :button, 'form input[type="submit"]'

      def login_with(user)
        email.set user.email
        password.set user.password
        button.click
      end
    end
  end
end

