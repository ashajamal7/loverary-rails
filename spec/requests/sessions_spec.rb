require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "POST /users" do
    let(:user_params) { { username: Faker::Name.name, email: Faker::Internet.email, password: Faker::Internet.password } }

    it 'registers a user properly when given valid credentials' do
      post '/users', params: { user: user_params }
      parsed = JSON.parse(response.body)
      puts "parsed: #{parsed}"

      expect(response).to have_http_status(:created)

      expect(parsed['user']['username']).to eq(user_params[:username])
      expect(parsed['user']['email']).to eq(user_params[:email])
    end
  end

  describe "POST /users/login" do
    let!(:user) { create(:user) }
    it 'successfully logs in a user and assigns a cart when provided correct credentials' do
      post '/users/login', params: { user: { email: user.email, password: user.password } }

      expect(response).to have_http_status(:ok)
      parsed = JSON.parse(response.body)
      expect(parsed['user']['username']).to eq(user.username)
      expect(parsed['user']['email']).to eq(user.email)
      expect(session[:user_id]).to eq(user.id)
      expect(session[:cart]).to eq({ user_id: user.id })
    end
  end
end
