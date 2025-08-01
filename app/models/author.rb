class Author < ApplicationRecord
  enum :gender, { male: 0, female: 1 }
  
  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  
  # Associations
  has_many :books, dependent: :destroy
  
  # Callbacks
  before_save :strip_whitespace
  
  private
  
  def strip_whitespace
    self.name = name.strip if name.present?
  end
end
