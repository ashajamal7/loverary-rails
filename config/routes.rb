Rails.application.routes.draw do
  # Serve static files from /storage
  get "/storage/*path" => "application#serve_storage", as: :storage
  get "/covers/*path" => "application#serve_storage", as: :covers

  # Public resources
  resources :books, only: %i[index show]
  resources :categories, only: %i[index show]
  resources :authors, only: %i[index show]

  # Protected resources - require authentication
  resources :reviews, only: %i[create update destroy]
  resources :shippings, only: %i[create update show]
  resources :order_items, only: %i[index show]

  # User-specific orders - scoped to current user
  scope :users do
    resources :orders, only: %i[index show create update]
  end

  # Authentication Routes
  post "/users", to: "users#create"
  post "/users/login", to: "sessions#login"
  delete "users/logout", to: "sessions#logout"
  get "/users/current", to: "sessions#current_user"
  get "/users/csrf-token", to: "sessions#csrf_token"

  # Cart Routes
  resources :carts, only: [ :create ] do
    collection do
      get "/", to: "carts#index", constraints: ->(req) { req.params[:status].present? }
      get "active", to: "carts#active"
      post "add", to: "carts#add"
      delete "remove/:book_id", to: "carts#remove"
      delete "clear", to: "carts#clear"
      post "checkout", to: "carts#checkout"
      patch "/", to: "carts#update"
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
