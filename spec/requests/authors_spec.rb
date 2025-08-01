require 'rails_helper'

RSpec.describe "/authors", type: :request do
  # Author. As you add validations to Author, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      name: 'J.K. Rowling',
      gender: 'female'
    }
  }

  let(:invalid_attributes) {
    {
      name: nil,  # This will trigger the presence validation
      gender: 'male'  # Using a valid gender value
    }
  }

  let(:author) { create(:author) }
  let(:user) { create(:user, email: 'test@example.com', password: 'password123') } # Make sure to include email and password for authentication

  before do
    # Log in the user by making a POST request to the correct login endpoint
    post '/users/login', params: { user: { email: user.email, password: 'password123' } }
    expect(response).to have_http_status(:ok) # Ensure login was successful
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      get authors_url
      expect(response).to be_successful
    end

    it 'returns all authors' do
      create_list(:author, 3)
      get authors_url
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      get author_url(author)
      expect(response).to be_successful
    end

    it 'returns the requested author' do
      get author_url(author)
      expect(JSON.parse(response.body)['id']).to eq(author.id)
    end

    it 'returns not found for non-existent author' do
      get author_url(id: 'invalid')
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Author' do
        expect {
          post authors_url, params: { author: valid_attributes }
        }.to change(Author, :count).by(1)
      end

      it 'returns the created author' do
        post authors_url, params: { author: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['name']).to eq(valid_attributes[:name])
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Author' do
        expect {
          post authors_url, params: { author: invalid_attributes }
        }.to change(Author, :count).by(0)
      end

      it 'returns unprocessable entity status' do
        post authors_url, params: { author: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) {
        {
          name: 'Updated Name',
          biography: 'Updated biography'
        }
      }

      it 'updates the requested author' do
        patch author_url(author), params: { author: new_attributes }
        author.reload
        expect(author.name).to eq('Updated Name')
      end

      it 'returns the updated author' do
        patch author_url(author), params: { author: new_attributes }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Updated Name')
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity status' do
        patch author_url(author), params: { author: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    let!(:author_to_delete) { create(:author) }

    it 'destroys the requested author' do
      expect {
        delete author_url(author_to_delete)
      }.to change(Author, :count).by(-1)
    end

    it 'returns no content status' do
      delete author_url(author_to_delete)
      expect(response).to have_http_status(:no_content)
    end

    context 'when author has books' do
      before do
        create(:book, author: author_to_delete)
      end

      it 'destroys the author and associated books' do
        expect {
          delete author_url(author_to_delete)
        }.to change(Author, :count).by(-1)
         .and change(Book, :count).by(-1)
      end
    end
  end
end

