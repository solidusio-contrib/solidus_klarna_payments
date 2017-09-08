module PageDrivers
  module Admin
    class LogEntry < SitePrism::Section
      element :message, :xpath, 'tbody/tr[1]/td[2]'
    end

    class Logs < SitePrism::Page
      set_url '/admin/orders/{number}/payments/{payment_id}/log_entries'
      sections :log_entries, LogEntry, '#listing_log_entries table.index'
    end
  end
end

