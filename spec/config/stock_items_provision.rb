if RSpec.configuration.inclusion_filter.rules.has_key?(:bdd)
  # BDD exectution
  Spree::StockItem.all.each do |item|
    if item.count_on_hand < 1000
      item.set_count_on_hand(1000)
      item.save
    end
  end
end
