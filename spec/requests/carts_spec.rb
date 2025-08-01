# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Carts", type: :request do
  let!(:user) { create(:user, password: "password123", password_confirmation: "password123") }
  let!(:book1) { create(:book, price: 19.34) }
  let!(:book2) { create(:book, price: 40.99) }

  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end

  before do
    post '/users/login', params: { user: { email: user.email, password: "password123" } }
  end

  describe "POST /users/:id/cart/add" do
    it_behaves_like "adds an item to the cart successfully"
  end

  describe "DELETE /users/:id/remove/:book_id" do
    before do
      post "/users/#{user.id}/cart/add", params: {
        items: [
          { book_id: book1.id, quantity: 1, price: book1.price },
          { book_id: book2.id, quantity: 2, price: book2.price }
        ]
      }
      expect(response).to have_http_status(:ok)
      expect(json_response[:cart][:count]).to eq(2)
    end

    it 'removes a cart item when it exists and user is logged in' do
      delete "/users/#{user.id}/cart/remove/#{book1.id}"
      expect(response).to have_http_status(:ok)
      expect(json_response[:cart][:count]).to eq(1)
    end
  end

  describe 'POST /users/:id/cart/clear' do
    before do
      post "/users/#{user.id}/cart/add", params: {
        items: [
          { book_id: book1.id, quantity: 1, price: book1.price },
          { book_id: book2.id, quantity: 2, price: book2.price }
        ]
      }
      expect(response).to have_http_status(:ok)
      expect(json_response[:cart][:count]).to eq(2)
    end

    it 'clears the cart items if there were items initially' do
      delete "/users/#{user.id}/cart/clear"
      expect(response).to have_http_status(:ok)
      expect(json_response[:message]).to eq("cart cleared")
      expect(json_response[:cart][:count]).to eq(0)
    end
  end

  describe 'POST /users/:id/cart' do
    before do
      post "/users/#{user.id}/cart/add", params: {
        items: [{ book_id: book1.id, quantity: 1, price: 20 }]
      }
      expect(response).to have_http_status(:ok)
      expect(json_response[:cart][:count]).to eq(1)
    end

    it 'sets the quantity of the item to the given quantity' do
      patch "/users/#{user.id}/cart", params: { book_id: book1.id, quantity: 2 }
      expect(response).to have_http_status(:ok)
      expect(json_response[:cart][:items][0][:quantity]).to eq(2)
    end
  end

  describe 'POST /users/:id/cart/checkout' do
    before do
      post "/users/#{user.id}/cart/add", params: {
        items: [
          { book_id: book1.id, quantity: 1, price: book1.price },
          { book_id: book2.id, quantity: 2, price: book2.price }
        ]
      }
      expect(response).to have_http_status(:ok)
      expect(json_response[:cart][:count]).to eq(2)
    end

    it 'checks out a user cart if its not empty(with valid cart items)' do
      post "/users/#{user.id}/cart/checkout"
      expect(response).to have_http_status(:ok)

      expect(json_response[:order]).to_not be_empty
      expect(json_response[:order][:total_price].to_f).to eq(((book1.price) + (book2.price * 2)).to_f)
    end
  end
end
