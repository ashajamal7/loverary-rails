require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "POST /users" do
    let(:user_params) { { username: Faker::Name.name, email: Faker::Internet.email, password: Faker::Internet.password } }

    it 'registers a user properly when given valid credentials' do
      post '/users', params: { user: user_params }
      parsed = JSON.parse(response.body)

      expect(response).to have_http_status(:created)
      expect(parsed['user']['username']).to eq(user_params[:username])
      expect(parsed['user']['email']).to eq(user_params[:email])
    end

    it 'returns error with invalid registration data' do
      post '/users', params: { user: { username: '', email: '', password: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /users/login" do
    let!(:user) { create(:user) }
    
    context 'with valid credentials' do
      before do
        post '/users/login', params: { user: { email: user.email, password: user.password } }
      end

      it 'successfully logs in a user' do
        expect(response).to have_http_status(:ok)
        parsed = JSON.parse(response.body)
        expect(parsed['user']['username']).to eq(user.username)
        expect(parsed['user']['email']).to eq(user.email)
      end

      it 'sets up the session correctly' do
        expect(session[:user_id]).to eq(user.id)
        expect(session[:cart]).to eq({ user_id: user.id, cart_items: [] })
      end

      it 'sets the user_id in session' do
        expect(session[:user_id]).to eq(user.id)
        # Check for the existence of the cookie without using signed method
        expect(response.cookies['user_id']).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized with incorrect password' do
        post '/users/login', params: { user: { email: user.email, password: 'wrongpassword' } }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized with non-existent email' do
        post '/users/login', params: { user: { email: 'nonexistent@example.com', password: 'password' } }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized with missing email' do
        post '/users/login', params: { user: { password: 'password' } }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized with missing password' do
        post '/users/login', params: { user: { email: user.email } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /logout" do
    let!(:user) { create(:user) }
    
    before do
      post '/users/login', params: { user: { email: user.email, password: user.password } }
      delete '/logout'
    end

    it 'logs out the user successfully' do
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('logout successful')
    end

    it 'clears the session' do
      expect(session[:user_id]).to be_nil
      expect(session[:cart]).to be_nil
    end
  end

  describe "GET /users/current" do
    context 'when user is logged in' do
      let!(:user) { create(:user) }
      
      before do
        post '/users/login', params: { user: { email: user.email, password: user.password } }
        get '/users/current'
      end

      it 'returns the current user' do
        expect(response).to have_http_status(:ok)
        parsed = JSON.parse(response.body)
        expect(parsed['id']).to eq(user.id)
        expect(parsed['email']).to eq(user.email)
      end
    end

    context 'when user is not logged in' do
      before { get '/users/current' }
      
      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
