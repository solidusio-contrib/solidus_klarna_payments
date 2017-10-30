module PageDrivers
  class GuestUser < SitePrism::Section
    element :email, "input#order_email"

    if KlarnaGateway.is_spree? && !KlarnaGateway.up_to_spree?('2.4.99')
      element :continue_button, "input.btn"
    else
      element :continue_button, "input.button"
    end
  end

  class Registration < Base
    set_url "/checkout/registration"

    section :guest_user, GuestUser, '#guest_checkout'

    def checkout_as_guest(email= 'test@test.com')
      guest_user.email.set email
      guest_user.continue_button.click
    end
  end
end

