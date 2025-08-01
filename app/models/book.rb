class Book < ApplicationRecord
  belongs_to :author
  has_many :reviews, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :isbn, presence: true, uniqueness: { case_sensitive: false }
  validates :language, presence: true
  validates :page_count, presence: true, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :by_author, ->(author_id) { where(author_id: author_id) }

  def update_average_rating
    average = reviews.average(:rating)
    update(average_rating: average)
  end
end
