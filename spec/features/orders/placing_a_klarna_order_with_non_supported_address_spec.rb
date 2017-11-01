require 'features_helper'

describe 'Orders to non-supported countries', type: 'feature', bdd: true, no_klarna: true, only: :us do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  let(:product_name) { 'Ruby on Rails Bag' }
  let(:product_quantity) { 2 }

  it 'Gateway should be unavailable when shipping to a non-supported country (Canada)' do
    order_on_state(product_name: product_name, state: :delivery, quantity: product_quantity, alternative_address: @testing_data.ca_address)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_payment_method(@testing_data.payment_name).click

      page.klarna_credit do |frame|
        expect(frame).to have_content('Not available for this country')
      end

      Capybara.current_session.driver.quit
    end
  end

  it 'Gateway should be unavailable when shipping to a non-supported country (Germany)' do
    order_on_state(product_name: product_name, state: :delivery, quantity: product_quantity, alternative_address: @testing_data.de_address)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_payment_method(@testing_data.payment_name).click

      page.klarna_credit do |frame|
        expect(frame).to have_content('Zahlungsart nicht verfügbar in diesem Land')
      end

      Capybara.current_session.driver.quit
    end
  end

  it 'Gateway should be unavailable when shipping to a non-supported country (UK)' do
    order_on_state(product_name: product_name, state: :delivery, quantity: product_quantity, alternative_address: @testing_data.uk_address)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_payment_method(@testing_data.payment_name).click

      page.klarna_credit do |frame|
        expect(frame).to have_content('Not available for this country')
      end

      Capybara.current_session.driver.quit
    end
  end

  it 'Gateway should be unavailable when shipping to a non-supported country (Norway)' do
    order_on_state(product_name: product_name, state: :delivery, quantity: product_quantity, alternative_address: @testing_data.no_address)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_payment_method(@testing_data.payment_name).click

      page.klarna_credit do |frame|
        expect(frame).to have_content('Ikke tilgjengelig i dette landet')
      end

      Capybara.current_session.driver.quit
    end
  end

  it 'Gateway should be unavailable when shipping to a non-supported country (Sweden)' do
    order_on_state(product_name: product_name, state: :delivery, quantity: product_quantity, alternative_address: @testing_data.se_address)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_payment_method(@testing_data.payment_name).click

      page.klarna_credit do |frame|
        expect(frame).to have_content('Betalsätt ej tillgängligt för det här landet')
      end

      Capybara.current_session.driver.quit
    end
  end

  it 'gateway should be unavailable when shipping to a non-supported country (Finland)' do
    order_on_state(product_name: product_name, state: :delivery, quantity: product_quantity, alternative_address: @testing_data.fi_address)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      page.select_payment_method(@testing_data.payment_name).click

      page.klarna_credit do |frame|
        expect(frame).to have_content('Maksutapa ei ole saatavilla tässä maassa')
      end

      Capybara.current_session.driver.quit
    end
  end

end
