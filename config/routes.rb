Rails.application.routes.draw do
  devise_for :users

  resources :results
  resources :bet_positions
  resources :bets do
    member do
      patch :reopen
    end
  end
  resources :races
  resources :drivers
  resources :users, only: [:show, :index] # usually avoid full CRUD for users

  get "up", to: "rails/health#show", as: :rails_health_check

  root "home#index"
end
