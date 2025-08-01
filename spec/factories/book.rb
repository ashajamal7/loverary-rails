# frozen_string_literal: true


FactoryBot.define do
  factory :book do
    isbn { Faker::Code.isbn }
    stock { rand(1..100) }
    title { Faker::Book.title }
    summary { Faker::Lorem.paragraph(sentence_count: 3) }
    price { Faker::Commerce.price(range: 10.0..100.0) }
    cover_url { Faker::Internet.url(host: 'covers.example.com') }
    published_date { Faker::Date.backward(days: 1000) }
    edition { rand(1..5) }
    language { %w[English French Spanish German].sample }
    page_count { rand(100..900) }

    # Associations
    association :author
  end
end
