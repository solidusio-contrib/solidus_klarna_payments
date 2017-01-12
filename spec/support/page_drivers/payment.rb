module PageDrivers
  class Payment < Base
    def select_klarna
      within 'fieldset#payment' do
        find("#order_payments_attributes__payment_method_id_5").click
      end
      wait_for_ajax
      within_frame 'klarna-credit-main' do
        wait_until { first('label').visible? }
        first('label').click
      end
      wait_for_ajax
    end


    def select_credit_card
      within 'fieldset#payment' do
        find("#order_payments_attributes__payment_method_id_2").click
      end
    end


    def select_check
      within 'fieldset#payment' do
        find("#order_payments_attributes__payment_method_id_3").click
      end
    end

    def continue
      click_button 'Save and Continue'
    end
  end
end

