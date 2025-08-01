FactoryBot.define do
  factory :review do
    sequence(:title) { |n| "Review Title #{n}" }
    comment { "This is a test review comment." }
    rating { 4 }  # Add default rating
    association :user
    association :book
    
    trait :with_long_comment do
      comment { "This is a very detailed review comment that provides comprehensive feedback about the book. " * 5 }
    end
    
    trait :with_short_comment do
      comment { "Good book!" }
    end
  end
end
