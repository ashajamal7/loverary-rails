class Shipping < ApplicationRecord
  belongs_to :order
  enum :status, { pending: 1, enroute: 2, delivered: 3 }
end
