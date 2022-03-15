# frozen_string_literal: true

SolidusKlarnaPayments::Engine.routes.draw do
  post '/api/callbacks/notification', to: '/solidus_klarna_payments/api/callbacks#notification', as: :notification
  post '/api/callbacks/push', to: '/solidus_klarna_payments/api/callbacks#push', as: :push

  post '/api/sessions', to: '/solidus_klarna_payments/api/sessions#create'
  get '/api/sessions', to: '/solidus_klarna_payments/api/sessions#show'
  get '/api/sessions/order_addresses', to: '/solidus_klarna_payments/api/sessions#order_addresses'

  # deprecated routes
  post '/callbacks/notification', to: '/solidus_klarna_payments/callbacks#notification'
  post '/callbacks/push', to: '/solidus_klarna_payments/callbacks#push'
  post '/sessions', to: '/solidus_klarna_payments/sessions#create'
  get '/sessions', to: '/solidus_klarna_payments/sessions#show'
  get '/sessions/order_addresses', to: '/solidus_klarna_payments/sessions#order_addresses'
end
