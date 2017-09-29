require 'features_helper'

describe 'Ordering with Klarna Payment Method Using Discount', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  unless KlarnaGateway.up_to_spree?('2.3.99')
    it 'Ordering with a system promotion' do
      unless Spree::Promotion.where(name: 'test').any?
        create(:promotion_with_item_total_rule, :with_order_adjustment, name: "test", description: 'test', code: 'test')
      end

      discount_code = if KlarnaGateway.is_spree?
                        Spree::Promotion.last.code
                      else
                        Spree::Promotion.last.codes.first.value
                      end

      expect(discount_code).to eq('test')

      order_product(product_name:  'Ruby on Rails Bag', testing_data: @testing_data, discount_code: discount_code)

      on_the_payment_page do |page|
        expect(page.displayed?).to be(true)

        page.select_klarna(@testing_data)
        page.continue(@testing_data)
      end

      if KlarnaGateway.is_solidus?
        on_the_confirm_page do |page|
          expect(page.displayed?).to be(true)

          order = Spree::Order.last
          promo_total = order.promo_total.to_f
          item_total = order.item_total.to_f

          expect(page).to have_content(item_total)
          # Multiply by -1 to flip to positive number
          expect(page).to have_content(promo_total*-1)
          expect(page).to have_content(order.total)
          page.continue
        end
      else
        order = Spree::Order.last
        promo_total = order.promo_total.to_f
        item_total = order.item_total.to_f
      end

      on_the_complete_page do |page|
        expect(page.displayed?).to be(true)
      end
   end
  end
end
