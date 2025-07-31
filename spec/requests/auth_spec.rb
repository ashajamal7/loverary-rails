require 'rails_helper'

require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  context 'on signup' do
    it "creates a new user successfully" do
      post "/users",
           params: {
             user: {
               email: "test@example.com",
               password: "password123",
               password_confirmation: "password123"
             }
           }.to_json,
           headers: {
             "CONTENT_TYPE" => "application/json",
             "ACCEPT" => "application/json"
           }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["email"]).to eq("test@example.com")
    end

  end
end

