module PageDrivers
  class Confirm < Base

    def wait_for_reauthorization
      wait_for_ajax
      expect(page).to have_css("form#checkout_form_confirm input.continue", visible: true)
    end

    def continue
      find("form#checkout_form_confirm input.continue").click
    end
  end
end
