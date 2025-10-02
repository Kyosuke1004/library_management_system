Rails.application.routes.draw do
  get 'users/index'
  root "books#index"
  devise_for :users
  resources :users do resources :loans, only: [:index] end
  resources :books
  resources :loans, only: [:create, :update]
  resources :authors, only: [] do
    collection do
      get :autocomplete
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
