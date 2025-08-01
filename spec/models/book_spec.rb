require 'rails_helper'

RSpec.describe Book, type: :model do
  let(:author) { create(:author) }
  let(:book) { create(:book, author: author) }

  describe 'validations' do
    let!(:book) { create(:book, author: author) }
    
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:isbn) }
    it { should validate_uniqueness_of(:isbn).case_insensitive }
    it { should validate_presence_of(:language) }
    it { should validate_presence_of(:page_count) }
    it { should validate_numericality_of(:page_count).is_greater_than(0) }
    it { should validate_numericality_of(:stock).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:author) }
    it { should have_many(:reviews).dependent(:destroy) }
  end

  describe '#update_average_rating' do
    let!(:book) { create(:book, author: author, average_rating: nil) }
    
    context 'when there are no reviews' do
      it 'sets average_rating to nil' do
        book.update_average_rating
        expect(book.average_rating).to be_nil
      end
    end

    context 'when there are reviews' do
      before do
        create_list(:review, 3, book: book, rating: 4)
        create_list(:review, 2, book: book, rating: 5)
        book.reload  # Make sure we have the latest reviews
      end

      it 'calculates the correct average rating' do
        book.update_average_rating
        expect(book.average_rating).to eq(4.4) # (4*3 + 5*2) / 5 = 4.4
      end

      it 'saves the average to the database' do
        book.update_column(:average_rating, nil) # Ensure it starts as nil
        expect {
          book.update_average_rating
        }.to change { book.reload.average_rating }.from(nil).to(4.4)
      end
    end
  end

  describe 'scopes' do
    describe '.by_author' do
      let!(:author1) { create(:author) }
      let!(:author2) { create(:author) }
      let!(:book1) { create(:book, author: author1) }
      let!(:book2) { create(:book, author: author2) }

      it 'returns books by the specified author' do
        expect(Book.by_author(author1.id)).to include(book1)
        expect(Book.by_author(author1.id)).not_to include(book2)
      end
    end
  end
end
