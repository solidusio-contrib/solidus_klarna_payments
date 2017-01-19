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
        if $data.us?
          wait_for_ajax
          expect(page).to have_css('label', visible: true)
          first('label').click
        end
      end
      sleep(3)
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

    def is_klarna_unappoved?
      wait_for_ajax
      within_frame 'klarna-credit-fullscreen' do
        if $data.de?
          expect(page).to have_content('Unable to approve application')
        else
          expect(page).to have_content('Unable to approve application')
        end
      end
    end
  end
end
