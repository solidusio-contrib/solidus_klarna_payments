# CURRENT FILE :: config/routes.rb
Spree::Core::Engine.routes.draw do

  post '/checkout/:state/klarna_session', to: 'checkout#klarna_session', as: :checkout_klarna_session
  post '/klarna/notification', to: 'klarna#notification', as: :klarna_notification

end
