if RSpec.configuration.inclusion_filter.rules.has_key?(:bdd)
  Spree::TaxRate.destroy_all
  Spree::Zone.destroy_all
  Spree::ShippingMethod.destroy_all


  test_data = TestData.new($store_id)

  Spree::Config.currency = test_data.currency
  Spree::Price.update_all(currency: test_data.currency)
  Spree::Store.update_all(default_currency: test_data.currency)

  if !Spree::Zone.find_by_name("Zone #{$store_id.upcase}")
    FactoryGirl.create(:zone, name: "Zone #{$store_id.upcase}", countries: [test_data.spree_country]).tap do |current_zone|
      FactoryGirl.create( :tax_rate,
                          name: "Tax on #{$store_id.upcase}",
                          tax_category: Spree::TaxCategory.first,
                          zone: current_zone,
                          included_in_price: !test_data.us?)
      FactoryGirl.create( :shipping_method,
                          name: "Shipping on #{$store_id.upcase}",
                          code: "SEND#{$store_id.upcase}",
                          tax_category: Spree::TaxCategory.first,
                          zones: [current_zone],
                          currency: test_data.currency)
    end
  end

  FactoryGirl.create(:global_zone).tap do |current_zone|
    current_zone.members.where(zoneable_id: test_data.spree_country.id).first.destroy

    FactoryGirl.create( :tax_rate,
                        name: "Tax International",
                        tax_category: Spree::TaxCategory.first,
                        zone: current_zone,
                        included_in_price: false)
    FactoryGirl.create( :shipping_method,
                        name: "Shipping International",
                        code: "SENDOUT",
                        tax_category: Spree::TaxCategory.first,
                        zones: [current_zone])
  end
end
