module PageDrivers
  module Admin
    class Logs < Base
      def has_logs?(counter)
        within 'div#listing_log_entries' do
          expect(page).to have_css('table.index', count: 2)
        end
      end

      def has_authorization_log?
        within 'div#listing_log_entries' do
          expect(page).to have_content('Placed order')
        end
      end

      def has_capture_log?
        within 'div#listing_log_entries' do
          expect(page).to have_content('Captured order')
        end
      end
    end
  end
end

