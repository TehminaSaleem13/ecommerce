require 'sidekiq/web'
Rails.application.routes.draw do
  root to: 'dashboard#index'
  get 'dashboard/index'

  post '/checkout/create', to: 'checkout#create', as: 'checkout_create'
  get '/checkout/success', to: 'checkout#success', as: 'checkout_success'

  post 'stripe/webhooks', to: 'stripe_webhooks#create'

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    sessions: 'users/sessions'
  }

  resources :products do
    resources :product_images, only: [:create, :destroy]
    resources :reviews, only: [:create, :update, :destroy, :edit]
  end

  resources :cart_items, only: [:create, :update, :destroy] do
    collection do
      post :apply_coupon
    end
  end

  resource :cart, only: [:show]

  resources :users, only: [:update]

  mount Sidekiq::Web => '/sidekiq'
end
