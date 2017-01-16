module PageDrivers
  module Admin
    class Payment < Base
      def is_valid?

      end

      def click_logs
        within '#content-header' do
          find('a[icon="archive"]').click
        end
      end
    end
  end
end

