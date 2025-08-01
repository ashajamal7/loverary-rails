require 'rails_helper'

RSpec.describe "/orders", type: :request do
  let(:user) { create(:user) }
  let(:book) { create(:book, price: 15.99) }
  
  # Order attributes
  let(:valid_attributes) {
    {
      user_id: user.id,
      status: 'pending',
      total_price: 0
    }
  }

  let(:invalid_attributes) {
    {
      user_id: nil,
      status: nil,
      total_price: -1
    }
  }

  let(:valid_headers) {
    {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  }

  before do
    # Authenticate the user (assuming you have authentication in place)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe 'GET /index' do
    let!(:order1) { create(:order, user: user, status: :pending) }
    let!(:order2) { create(:order, user: user, status: :completed) }
    
    it 'returns a list of orders' do
      get orders_url, headers: valid_headers, as: :json
      
      expect(response).to be_successful
      expect(json_response.size).to eq(2)
      expect(json_response.map { |o| o['id'] }).to match_array([order1.id, order2.id])
    end
  end

  describe 'GET /show' do
    let!(:order) { create(:order, user: user) }
    
    it 'returns the order details' do
      get order_url(order), headers: valid_headers, as: :json
      
      expect(response).to be_successful
      expect(json_response['id']).to eq(order.id)
      expect(json_response['status']).to eq('pending')
    end
    
    it 'returns 404 for non-existent order' do
      get order_url(999), headers: valid_headers, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new order' do
        expect {
          post orders_url,
               params: { order: valid_attributes },
               headers: valid_headers,
               as: :json
        }.to change(Order, :count).by(1)
        
        expect(response).to have_http_status(:created)
        expect(json_response['user_id']).to eq(user.id)
        expect(json_response['status']).to eq('pending')
      end
    end
    
    context 'with invalid parameters' do
      it 'does not create a new order' do
        expect {
          post orders_url,
               params: { order: invalid_attributes },
               headers: valid_headers,
               as: :json
        }.not_to change(Order, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to have_key('errors')
      end
    end
  end

  describe 'PATCH /update' do
    let!(:order) { create(:order, user: user, status: 'pending') }
    
    context 'with valid parameters' do
      let(:new_attributes) {
        { status: 'completed' }
      }
      
      it 'updates the order' do
        patch order_url(order),
              params: { order: new_attributes },
              headers: valid_headers,
              as: :json
              
        order.reload
        expect(order.status).to eq('completed')
        expect(response).to have_http_status(:ok)
      end
    end
    
    context 'with invalid parameters' do
      it 'returns unprocessable_entity status' do
        patch order_url(order),
              params: { order: { total_price: -1 } },
              headers: valid_headers,
              as: :json
              
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to have_key('errors')
      end
    end
  end
  
  describe 'DELETE /destroy' do
    let!(:order) { create(:order, user: user) }
    
    it 'destroys the order' do
      expect {
        delete order_url(order), headers: valid_headers, as: :json
      }.to change(Order, :count).by(-1)
      
      expect(response).to have_http_status(:no_content)
    end
    
    it 'destroys associated order items' do
      create(:order_item, order: order, book: book, quantity: 1)
      
      expect {
        delete order_url(order), headers: valid_headers, as: :json
      }.to change(OrderItem, :count).by(-1)
    end
  end
  
  # Helper method to parse JSON responses
  def json_response
    JSON.parse(response.body)
  end
end
