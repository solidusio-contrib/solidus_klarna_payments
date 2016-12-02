# CURRENT FILE :: config/routes.rb
Spree::Core::Engine.routes.draw do

  post '/checkout/:state/klarna_session', to: 'checkout#klarna_session', as: :checkout_klarna_session
  get '/checkout/:state/klarna_order_status', to: 'checkout#order_status', as: :checkout_klarna_order_status
  get '/checkout/:state/klarna_order_addresses', to: 'checkout#order_addresses', as: :checkout_klarna_order_addresses

  post '/klarna/notification', to: 'klarna#notification', as: :klarna_notification

  post '/klarna/push', to: 'klarna#push', as: :klarna_push

  get '/admin/orders/:id/klarna', to: 'admin/orders#klarna', as: :admin_order_klarna
  post '/admin/orders/:id/klarna_update', to: 'admin/orders#klarna_update', as: :admin_order_klarna_update
  post '/admin/orders/:id/klarna_extend', to: 'admin/orders#klarna_extend', as: :admin_order_klarna_extend
  post '/admin/orders/:id/klarna_release', to: 'admin/orders#klarna_release', as: :admin_order_klarna_release

end
