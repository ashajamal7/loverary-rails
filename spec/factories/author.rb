# frozen_string_literal: true


FactoryBot.define do
  factory :author do
    name { Faker::Book.author }
    gender { Faker::Gender.binary_type.downcase }
  end
end
