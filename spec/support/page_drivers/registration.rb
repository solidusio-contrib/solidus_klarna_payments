module PageDrivers
  class Registration < Base
    def checkout_as_guest(email= 'test@test.com')
      within '#guest_checkout' do
        fill_in 'Email', with:email
        click_button 'Continue'
      end
    end
  end
end

