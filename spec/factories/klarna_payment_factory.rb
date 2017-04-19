FactoryGirl.define do

  factory :klarna_credit_payment_method, class: Spree::Gateway::KlarnaCredit do
    name 'Klarna Credit'
    description 'Klarna Credit'

    preferences(api_secret: "DUMMY", api_key: "DUMMY")
  end

  factory :klarna_credit_payment, class: Spree::KlarnaCreditPayment do
    user

    order_id '1234-123-123'
    authorization_token 'asldfjasfdlasfaslkdfjaslkdfjhasifudp98q3h4irufhaosidufalsdf'
    redirect_url 'http://localhost:3000/someurl'


    factory :error_klarna_credit_payment do
      error_code 'NOT_VALID'
      error_messages 'Errored message'
      correlation_id '2345-2345-234'
    end
  end

  factory :klarna_payment, class: Spree::Payment do
    association(:payment_method, factory: :klarna_credit_payment_method)
    association(:source, factory: :klarna_credit_payment)
    order
  end
end
