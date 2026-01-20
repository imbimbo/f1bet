Rails.application.routes.draw do
  devise_for :users

  resources :results
  resources :bet_positions
  resources :bets
  resources :races do
    post "bets/save_positions", to: "bets#save_positions"
  end
  resources :drivers
  resources :users, only: [:show, :index] # usually avoid full CRUD for users

  get "up", to: "rails/health#show", as: :rails_health_check

  root "home#index"
end
