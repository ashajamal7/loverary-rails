FactoryBot.define do
  factory :order do
    status { :pending }  # Using symbol to match enum definition
    total_price { "9.99" }

    association :user
  end
end
