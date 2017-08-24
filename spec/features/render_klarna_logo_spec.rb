require 'features_helper'

describe 'renders Klarna logos on checkout', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'renders the main img logo from the CDN after klarna is selected' do
    order_product(product_name: 'Ruby on Rails Bag', testing_data: @testing_data)

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)

      page.select_klarna(@testing_data)
      expect(page).to have_selector("img[src$='https://cdn.klarna.com/1.0/shared/image/generic/logo/en_us/basic/white.png?width=80']", visible: true)
    end
  end

  it 'renders the footer svg logo from the CDN after klarna is selected' do
    order_product(product_name: 'Ruby on Rails Bag', testing_data: @testing_data)

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_klarna(@testing_data)

      page.klarna_credit do |frame|
        expect(frame).to have_css('svg._1Qyng')
      end
    end
  end
end
