# frozen_string_literal: true

module TestHelpers
  module CheckoutHelper
    def create_and_stub_order
      order = Spree::TestingSupport::OrderWalkthrough.up_to(:delivery)

      # To work around an issue in the Solidus :address factory
      if Spree.solidus_gem_version < Gem::Version.new('2.11')
        order.ship_address_attributes = order.ship_address.attributes.merge(lastname: 'Doe')
        order.bill_address_attributes = order.bill_address.attributes.merge(lastname: 'Doe')
        order.save!
      end

      user = create(:user)
      order.user = user
      order.recalculate

      allow_any_instance_of(Spree::StoreController).to receive_messages(current_order: order)
      allow_any_instance_of(Spree::StoreController).to receive_messages(try_spree_current_user: user)

      setup_store_urls

      order
    end

    def setup_klarna
      Spree::PaymentMethod.where(name: 'Klarna US').first_or_create! do |payment_method|
        payment_method.type = 'Spree::Gateway::KlarnaCredit'
        payment_method.preferences = {
          server: 'test',
          test_mode: true,
          api_key: 'PN02334_81166e4b64df',
          api_secret: 'rp5RInD6lL1b53TE',
          country: 'us',
        }
      end
    end

    def setup_check
      Spree::PaymentMethod.where(name: 'Check').first_or_create! do |payment_method|
        payment_method.type = 'Spree::PaymentMethod::Check'
      end
    end

    def setup_store_urls
      Spree::Store.all.find_each do |store|
        store.update!(url: "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}")
      end
    end
  end
end

RSpec.configure do |config|
  config.include TestHelpers::CheckoutHelper, type: :feature
end
