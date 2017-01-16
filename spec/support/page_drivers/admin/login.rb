module PageDrivers
  module Admin
    class Login < Base

      def login_with(user)
        expect(page).to have_content('Admin Login')
        within 'form' do
          fill_in "spree_user_email", with: user.email
          fill_in "spree_user_password", with: user.password
          find('input.button').click
        end
      end
    end
  end
end

