Spree::Core::Engine.routes.draw do
  namespace :klarna do
    resource :session, only: [:create, :show] do
      collection do
        get :order_addresses
      end
    end
    post '/callbacks/notification', to: 'callbacks#notification', as: :notification
    post '/callbacks/push', to: 'callbacks#push', as: :push
  end
end
