# Stolen from http://railsware.com/blog/2015/02/11/responsive-layout-tests-with-capybara-and-rspec/
# Thanks loads!

module ResponsiveHelpers
  def resize_window_to_phone
    resize_window_by([321, 540])
  end

  def resize_window_to_sidenav
    resize_window_by([361, 540])
  end

  def resize_window_to_login_min
    resize_window_by([601, 540])
  end

  def resize_window_to_tablet
    resize_window_by([769, 512])
  end

  def resize_window_desktop
    resize_window_by([1024, 768])
  end

  def resize_window_desktop_store
    resize_window_by([1301, 1200])
  end

  def resize_window_desktop_large
    resize_window_by([1441, 768])
  end

  private

  # Move the screen and resize to avoid maximized screen where some test fails
  def resize_window_by(size)
    if Capybara.current_session.driver.browser.respond_to? 'manage'
      Capybara.current_session.driver.browser.manage.window.move_to(1,1)
      Capybara.current_session.driver.browser.manage.window.resize_to(size[0], size[1])
    end
  end
end
