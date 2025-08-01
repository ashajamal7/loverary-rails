class User < ApplicationRecord
  has_secure_password

  has_many :orders
  has_many :order_items, through: :orders

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true
end
