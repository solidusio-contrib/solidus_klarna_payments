require 'features_helper'

describe 'Ordering with Klarna Payment Method Using Discount', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  unless KlarnaGateway.up_to_spree?('2.3.99')
    it 'Ordering with a system promotion' do
      promotion = unless Spree::Promotion.where(name: 'test').any?
                    create(:promotion_with_item_total_rule, :with_order_adjustment, name: "test", description: 'test', code: 'test')
                  else
                    Spree::Promotion.where(name: 'test').first
                  end

      klarna_order = order_on_state(product_name: 'Ruby on Rails Bag', state: :delivery, quantity: 1, promotion: promotion)

      on_the_payment_page do |page|
        page.load
        page.update_hosts
      end

      pay_with_klarna(testing_data: @testing_data)

      if KlarnaGateway.is_solidus?
        on_the_confirm_page do |page|
          expect(page.displayed?).to be(true)

          promo_total = klarna_order.promo_total.to_f
          item_total = klarna_order.item_total.to_f

          expect(page).to have_content(item_total)
          # Multiply by -1 to flip to positive number
          expect(page).to have_content(promo_total*-1)
          expect(page).to have_content(klarna_order.total)
          page.continue
        end
      else
        on_the_complete_page do |page|
          expect(page.displayed?).to be(true)
        end
      end

      Capybara.current_session.driver.quit
   end
  end
end
