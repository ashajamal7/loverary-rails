class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :book

  # Validations
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Callbacks
  before_validation :set_price_from_book, if: -> { price.blank? && book.present? }
  before_save :calculate_total_price
  after_save :update_order_total
  after_destroy :update_order_total_after_destroy

  # Calculate total price for this order item
  def total_price
    price.to_d * quantity.to_i
  end

  private

  def set_price_from_book
    self.price = book.price if book&.price.present?
  end

  def calculate_total_price
    # No need to store total_price as it can be calculated
    # This method is kept for backward compatibility
  end

  def update_order_total
    order.update_total!
  end

  def update_order_total_after_destroy
    order.update_total! if order.persisted?
  end
end
