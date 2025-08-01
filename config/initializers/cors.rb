# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:5173" # Your frontend URL
    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "ETag", "access-token", "expiry", "token-type", "uid", "client", "Authorization" ],
      credentials: true,
      max_age: 600
  end

  # Allow CORS for Active Storage
  allow do
    origins "*" # For development only - more permissive for Active Storage
    resource "/rails/active_storage/*",
      headers: :any,
      methods: [ :get, :options, :head ],
      credentials: false,
      max_age: 600
  end
end
