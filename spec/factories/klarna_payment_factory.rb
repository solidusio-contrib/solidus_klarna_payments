FactoryGirl.define do
  factory :rand_store, parent: :store do
    sequence(:code) { |i| "spree_#{i*rand(99999)}" }
  end


  factory :klarna_credit_payment_method, class: Spree::Gateway::KlarnaCredit do
    name 'Klarna'
    description 'Klarna'

    preferences(
      api_key: ENV.fetch("KLARNA_API_KEY") { "DUMMY" },
      api_secret: ENV.fetch("KLARNA_API_SECRET") { "DUMMY" })
  end

  factory :klarna_credit_payment, class: Spree::KlarnaCreditPayment do
    user
    sequence(:order_id){|n| "1234-123-#{n}"}
    sequence(:authorization_token){|n| "asldfjasfdlasfaslkdfjaslkdfjhasifudp98q3h4irufhaosidufalsdf#{n}"}
    redirect_url 'http://localhost:3000/someurl'

    factory :error_klarna_credit_payment do
      error_code 'NOT_VALID'
      error_messages 'Errored message'
      sequence(:correlation_id){|n| "2345-2345-#{n}"}
    end
  end

  factory :rand_store_order, parent: :order do
    association(:store, factory: :rand_store)
  end

  factory :klarna_payment, class: Spree::Payment do
    association(:payment_method, factory: :klarna_credit_payment_method)
    association(:source, factory: :klarna_credit_payment)
    association(:order, factory: :rand_store_order)
  end
end
