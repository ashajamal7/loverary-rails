require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:user) { create(:user) }
  let(:book) { create(:book) }
  let(:review) { create(:review, user: user, book: book) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:book) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(100) }
    it { should validate_presence_of(:comment) }
    it { should validate_length_of(:comment).is_at_most(1000) }
    it { should validate_presence_of(:rating) }
    it { should validate_numericality_of(:rating).only_integer
                                               .is_greater_than_or_equal_to(1)
                                               .is_less_than_or_equal_to(5) }
  end

  describe 'scopes' do
    let!(:recent_review) { create(:review, created_at: 1.day.ago) }
    let!(:old_review) { create(:review, created_at: 1.week.ago) }

    it 'returns reviews in reverse chronological order' do
      expect(Review.most_recent).to eq([ recent_review, old_review ])
    end
  end

  describe 'callbacks' do
    context 'after_save' do
      it 'updates the book average rating' do
        expect {
          create(:review, book: book, rating: 4)
        }.to change { book.reload.average_rating }.from(nil).to(4.0)
      end

      it 'recalculates average when review is updated' do
        review = create(:review, book: book, rating: 4)
        expect {
          review.update(rating: 5)
        }.to change { book.reload.average_rating }.from(4.0).to(5.0)
      end
    end
  end

  describe 'instance methods' do
    describe '#formatted_created_at' do
      it 'returns the formatted creation date' do
        review = create(:review, created_at: Time.zone.local(2023, 1, 1))
        expect(review.formatted_created_at).to eq('January 01, 2023')
      end
    end
  end
end
