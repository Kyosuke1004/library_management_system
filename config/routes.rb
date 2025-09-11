Rails.application.routes.draw do
  root "books#index"
  devise_for :users
  resources :books
  resources :loans
  get "up" => "rails/health#show", as: :rails_health_check
end
