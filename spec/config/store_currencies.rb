if Spree::Zone.where(name: 'GlobalZone').none?
  shipping_method = FactoryGirl.create(:shipping_method)
else
  shipping_method = Spree::ShippingMethod.last
end

if $store_id != 'us'
  euro_zone = Spree::Zone.find_by!(name: "EU_VAT")
  tax_rate = Spree::TaxRate.find_by(name: "USt.") ||
    FactoryGirl.create(:tax_rate, name: "USt.", tax_category: Spree::TaxCategory.first, included_in_price: true, zone: euro_zone)
  euro_zone.update(default_tax: true)
end

case $store_id
  when 'us'
    Spree::Config.currency = 'USD'
    Spree::Price.update_all(currency: 'USD')
    Spree::Store.update_all(default_currency: 'USD')
  when 'de'
    Spree::Config.currency = 'EUR'
    Spree::Price.update_all(currency: 'EUR')
    Spree::Store.update_all(default_currency: 'EUR')
  when 'uk'
    Spree::Config.currency = 'GBP'
    Spree::Price.update_all(currency: 'GBP')
    Spree::Store.update_all(default_currency: 'GBP')

    shipping_method.calculator.tap do |calculator|
      calculator.preferences = {:amount=>10.0, :currency=>"GBP"}
      calculator.save
    end
  when 'no'
    Spree::Config.currency = 'NOK'
    Spree::Price.update_all(currency: 'NOK')
    Spree::Store.update_all(default_currency: 'NOK')

    shipping_method.calculator.tap do |calculator|
      calculator.preferences = {:amount=>10.0, :currency=>"NOK"}
      calculator.save
    end
  when 'se'
    Spree::Config.currency = 'SEK'
    Spree::Price.update_all(currency: 'SEK')
    Spree::Store.update_all(default_currency: 'SEK')

    shipping_method.calculator.tap do |calculator|
      calculator.preferences = {:amount=>10.0, :currency=>"SEK"}
      calculator.save
    end
  when 'fi'
    Spree::Config.currency = 'EUR'
    Spree::Price.update_all(currency: 'EUR')
    Spree::Store.update_all(default_currency: 'EUR')
end
