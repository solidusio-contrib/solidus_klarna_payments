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
end
