module PageDrivers
  class GuestUser < SitePrism::Section
    element :email, "input#order_email"
    element :continue_button, "input.button"
  end

  class Registration < SitePrism::Page
    set_url "/checkout/registration"

    section :guest_user, GuestUser, '#guest_checkout'

    def checkout_as_guest(email= 'test@test.com')
      guest_user.email.set email
      guest_user.continue_button.click
    end
  end
end

