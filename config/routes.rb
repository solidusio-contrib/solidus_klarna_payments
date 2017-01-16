# CURRENT FILE :: config/routes.rb
Spree::Core::Engine.routes.draw do

  post '/checkout/:state/klarna_session', to: 'checkout#klarna_session', as: :checkout_klarna_session
  get '/checkout/:state/klarna_order_status', to: 'checkout#order_status', as: :checkout_klarna_order_status
  get '/checkout/:state/klarna_order_addresses', to: 'checkout#order_addresses', as: :checkout_klarna_order_addresses
  post '/checkout/:state/klarna_update_session', to: 'checkout#klarna_update_session', as: :checkout_klarna_update_session

  post '/klarna/notification', to: 'klarna#notification', as: :klarna_notification

  post '/klarna/push', to: 'klarna#push', as: :klarna_push
end
