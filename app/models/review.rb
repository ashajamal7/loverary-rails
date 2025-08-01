class Review < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :book

  # Validations
  validates :title, presence: true, length: { maximum: 100 }
  validates :comment, presence: true, length: { maximum: 1000 }
  validates :rating, presence: true, 
                    numericality: { only_integer: true, 
                                  greater_than_or_equal_to: 1, 
                                  less_than_or_equal_to: 5 }

  # Scopes
  scope :most_recent, -> { order(created_at: :desc) }

  # Callbacks
  after_save :update_book_average_rating
  after_destroy :update_book_average_rating_after_destroy

  # Instance Methods
  def formatted_created_at
    created_at.strftime('%B %d, %Y')
  end

  private

  def update_book_average_rating
    book.update_average_rating
  end

  def update_book_average_rating_after_destroy
    book.update_average_rating
  end
end
