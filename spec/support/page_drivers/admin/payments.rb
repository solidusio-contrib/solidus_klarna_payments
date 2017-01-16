module PageDrivers
  module Admin
    class Payments < PageDrivers::Base
      def is_check?
        within '[data-hook="payment_list"] tbody' do
          expect(page).to have_content('Check')
        end
      end

      def is_klarna?
        within '[data-hook="payment_list"] tbody' do
          expect(page).to have_css('tr.klarna_payment')
        end
      end

      def is_pending?
        within '[data-hook="payment_list"] tbody' do
          expect(first('tr')).to have_css('span.pending')
        end
      end

      def is_completed?
        within '[data-hook="payment_list"] tbody' do
          expect(first('tr')).to have_css('span.completed')
        end
      end

      def is_klarna_authorized?
        within '[data-hook="payment_list"] tbody' do
          expect(find('tr.klarna_payment')).to have_content('AUTHORIZED')
        end
      end

      def show_first_payment
        first('[data-hook="payment_list"] tbody tr').first('a').click
      end

      def capture
        find('[data-hook="payment_list"] tbody tr.payment [data-action="capture"]').click
      end

      def is_klarna_captured?
        within '[data-hook="payment_list"] tbody' do
          expect(find('tr.klarna_payment')).to have_content('CAPTURED')
        end
      end
    end
  end
end

