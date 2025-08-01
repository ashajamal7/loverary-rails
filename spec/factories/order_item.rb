FactoryBot.define do
  factory :order_item do
    quantity { 1 }
    price { "19.99" }

    association :order
    association :book
  end
end
