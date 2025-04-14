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
  end

  resources :users, only: [:update]
end
