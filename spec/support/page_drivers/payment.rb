module PageDrivers
  class Payment < Base

    def select_klarna
      within 'fieldset#payment' do
        all('#payment-method-fields label').find{|e| e.text.match(/Klarna/)}.click
      end
      wait_for_ajax
      wait_until(CapybaraDefaultMaxWaitTime) do
        wait_for_ajax
        find('iframe#klarna-credit-main').visible?
      end

      within_frame 'klarna-credit-main' do
        sleep(3)
        if $data.us?
          wait_until(CapybaraDefaultMaxWaitTime) do
            wait_for_ajax
            find('iframe#klarna-credit-main label').visible?
          end
          first('label').click
        end
      end
      wait_for_ajax
    end


    def select_credit_card
      within 'fieldset#payment' do
        all('#payment-method-fields label').find{|e| e.text.match(/Credit Card/)}.click
      end
    end


    def select_check
      within 'fieldset#payment' do
        all('#payment-method-fields label').find{|e| e.text.match(/Check/)}.click
      end
    end

    def continue
      expect(page).to have_css("form#checkout_form_payment input.continue", visible: true)
      find("form#checkout_form_payment input.continue").click
      wait_for_ajax

      if $data.de?
        within_frame 'klarna-credit-fullscreen' do
          fill_in 'purchaseApproval-dataCollection-dateOfBirth', with: '10.10.1970'
          find('#purchaseApproval-dataCollection-agreeCheckbox').click
          find('button#purchaseApproval-continueButton').click
        end
        wait_for_ajax
      end
    end
  end
end
