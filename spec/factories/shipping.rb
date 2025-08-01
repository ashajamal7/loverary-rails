FactoryBot.define do
  factory :shipping do
    association :order
    address { "123 Main St, Anytown, AN 12345" }
    status { 0 } 
    tracking_code { "TRK#{SecureRandom.hex(5).upcase}" }
    
    trait :pending do
      status { 1 } 
      shipped_at { Time.current }
    end
    
    trait :enroute do
      status { 2 } 
      shipped_at { 1.week.ago }
    end
    
    trait :delivered do
      status { 3 } 
      shipped_at { 1.week.ago }
    end
    
    trait :with_custom_address do
      address { "456 Custom St, Othertown, OT 67890" }
    end
  end
end
