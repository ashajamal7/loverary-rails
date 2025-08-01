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

  # Cart Routes
  post "users/:id/cart/add", to: "carts#add"
  delete "/users/:id/cart/remove/:book_id", to: "carts#remove"
  delete "/users/:id/cart/clear", to: "carts#clear"
  post "/users/:id/cart/checkout", to: "carts#checkout"
  patch "/users/:id/cart", to: "carts#update"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
