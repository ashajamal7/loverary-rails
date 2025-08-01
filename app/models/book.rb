class Book < ApplicationRecord
  belongs_to :author
  belongs_to :category
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

  # Converts a relative URL to an absolute URL for image serving
  # @param url [String] The relative URL of the image
  # @return [String, nil] The absolute URL or nil if the input is blank
  def ensure_absolute_url(url)
    return nil if url.blank?
    return url if url.start_with?("http://", "https://")

    # Clean the URL by removing any leading/trailing slashes and 'covers/' prefix if present
    clean_url = url.gsub(%r{^/|/$}, "").gsub(%r{^covers/}, "")

    # For local development
    if Rails.env.development? || Rails.env.test?
      "http://localhost:3000/covers/#{clean_url}"
    else
      # For production, use your actual domain
      "https://your-production-domain.com/covers/#{clean_url}"
    end
  end
end
