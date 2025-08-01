class Order < ApplicationRecord
  belongs_to :user
  enum :status, { pending: 1, fulfilled: 2 }
end
