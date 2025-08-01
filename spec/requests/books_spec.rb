require 'rails_helper'

RSpec.describe "/books", type: :request do
  let(:author) { create(:author) }
  let(:valid_attributes) {
    {
      title: 'Sample Book',
      isbn: '978-3-16-148410-0',
      language: 'English',
      page_count: 300,
      stock: 10,
      price: 29.99,
      author_id: author.id,
      summary: 'A great book',
      published_date: '2023-01-01',
      edition: 1
    }
  }

  let(:invalid_attributes) {
    {
      title: nil,
      isbn: nil,
      language: nil,
      page_count: 0,
      stock: -1,
      price: -1,
      author_id: nil
    }
  }

  let(:valid_headers) {
    { 'Content-Type' => 'application/json' }
  }

  describe 'GET /index' do
    let!(:book) { create(:book, author: author) }

    it 'returns a successful response' do
      get books_url, as: :json
      expect(response).to be_successful
    end

    it 'returns all books' do
      get books_url, as: :json
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe 'GET /show' do
    let!(:book) { create(:book, author: author) }

    it 'returns a successful response' do
      get book_url(book), as: :json
      expect(response).to be_successful
    end

    it 'returns the correct book' do
      get book_url(book), as: :json
      expect(JSON.parse(response.body)['id']).to eq(book.id)
    end

    it 'returns 404 for non-existent book' do
      get book_url(id: 'invalid'), as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new book' do
        expect {
          post books_url,
               params: { book: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Book, :count).by(1)
      end

      it 'returns the created book' do
        post books_url,
             params: { book: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
        expect(JSON.parse(response.body)['title']).to eq('Sample Book')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new book' do
        expect {
          post books_url,
               params: { book: invalid_attributes }, headers: valid_headers, as: :json
        }.not_to change(Book, :count)
      end

      it 'returns unprocessable entity status' do
        post books_url,
             params: { book: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        post books_url,
             params: { book: invalid_attributes }, headers: valid_headers, as: :json
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end
  end

  describe 'PATCH /update' do
    let!(:book) { create(:book, author: author) }
    let(:new_attributes) {
      {
        title: 'Updated Book Title',
        price: 39.99,
        stock: 5
      }
    }

    context 'with valid parameters' do
      it 'updates the requested book' do
        patch book_url(book),
              params: { book: new_attributes }, headers: valid_headers, as: :json
        book.reload
        expect(book.title).to eq('Updated Book Title')
        expect(book.price).to eq(39.99)
        expect(book.stock).to eq(5)
      end

      it 'returns the updated book' do
        patch book_url(book),
              params: { book: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['title']).to eq('Updated Book Title')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the book' do
        original_title = book.title
        patch book_url(book),
              params: { book: invalid_attributes }, headers: valid_headers, as: :json
        book.reload
        expect(book.title).to eq(original_title)
      end

      it 'returns unprocessable entity status' do
        patch book_url(book),
              params: { book: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        patch book_url(book),
              params: { book: invalid_attributes }, headers: valid_headers, as: :json
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end
  end

  describe 'DELETE /destroy' do
    let!(:book) { create(:book, author: author) }

    it 'destroys the requested book' do
      expect {
        delete book_url(book), headers: valid_headers, as: :json
      }.to change(Book, :count).by(-1)
    end

    it 'returns no content status' do
      delete book_url(book), headers: valid_headers, as: :json
      expect(response).to have_http_status(:no_content)
    end

    it 'returns not found for non-existent book' do
      delete book_url(id: 'invalid'), headers: valid_headers, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end
