# CURRENT FILE :: config/routes.rb
Spree::Core::Engine.routes.draw do

  post '/checkout/:state/klarna_session', to: 'checkout#klarna_session', as: :checkout_klarna_session
  post '/checkout/:state/klarna_reauthorize', to: 'checkout#klarna_reauthorize', as: :checkout_klarna_reauthorize

  post '/klarna/notification', to: 'klarna#notification', as: :klarna_notification

  post '/klarna/push', to: 'klarna#push', as: :klarna_push
end
