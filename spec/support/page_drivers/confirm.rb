module PageDrivers
  class Confirm < Base
    def change_payment
      expect(page).to have_css('ol#checkout-step-confirm a', count: 3)
      all('ol#checkout-step-confirm a').find{|e| e[:href].match(/payment/)}.click
    end

    def wait_for_reauthorization
      wait_for_ajax
      expect(page).to have_css("form#checkout_form_confirm input.continue", visible: true)
    end

    def continue
      find("form#checkout_form_confirm input.continue").click
    end
  end
end
