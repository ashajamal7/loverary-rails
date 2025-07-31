Rails.application.routes.draw do
  resources :carts
  resources :reviews
  resources :shippings
  resources :order_items
  resources :orders
  resources :books
  resources :categories
  resources :authors
  # Authentication Routes
  post "/users", to: "users#create"
  post "/users/login", to: "sessions#login"
  post "/users/logout", to: "sessions#logout"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
