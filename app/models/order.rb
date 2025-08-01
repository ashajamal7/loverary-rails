class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :books, through: :order_items
  
  enum :status, {
    pending: 0,
    processing: 1,
    completed: 2,
    cancelled: 3
  }, prefix: :status
  
  after_initialize :set_default_status, if: :new_record?
  after_initialize :initialize_total_price, if: :new_record?
  
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Recalculates the total price based on order items
  def update_total!
    total = order_items.sum { |item| (item.price * item.quantity).round(2) }
    update_column(:total_price, total)
  end
  
  def add_book(book, quantity = 1)
    order_items.create(book: book, quantity: quantity, price: book.price)
    update_total!
  end
  
  def complete!
    update!(status: :completed)
  end
  
  def cancel!
    update!(status: :cancelled)
  end
  
  # This is needed for the test to pass
  def self.human_attribute_name(attribute, options = {})
    super
  end
  
  private
  
  def set_default_status
    self.status ||= :pending
  end
  
  def initialize_total_price
    self.total_price ||= 0
  end
end
