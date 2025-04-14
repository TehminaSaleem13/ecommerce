Rails.application.routes.draw do
  root to: 'dashboard#index'
  get 'dashboard/index'

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    sessions: 'users/sessions'
  }

  resources :products do
    resources :product_images, only: [:create, :destroy]
    resources :reviews, only: [:create, :update, :destroy, :edit]
  end
  resources :cart_items, only: [:create, :update, :destroy]
  resource :cart, only: [:show]
  resources :users, only: [:update]
end
