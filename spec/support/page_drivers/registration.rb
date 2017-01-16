module PageDrivers
  class Registration < Base
    def checkout_as_guest(email= 'test@test.com')
      within '#guest_checkout' do
        fill_in 'order_email', with: email
        find('input.button').click
      end
    end
  end
end

