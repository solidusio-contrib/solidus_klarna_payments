class LoginPage < SitePrism::Page
  set_url "/login"

  element :email_field, "#spree_user_email"
  element :password_field, "#spree_user_password"
  element :login_button, "#new_spree_user input[type='submit']"

  def login(user, password)
    email_field.set user.email
    password_field.set password
    login_button.click
  end
end
