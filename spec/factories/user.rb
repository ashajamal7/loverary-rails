FactoryBot.define do
  factory :user do
    username {  Faker::Name.name  }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password(min_length: 8) }
  end
end