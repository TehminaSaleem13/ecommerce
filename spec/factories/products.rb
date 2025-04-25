FactoryBot.define do
  factory :product do
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    price { Faker::Commerce.price(range: 10..100.0) }
    quantity { Faker::Number.between(from: 1, to: 100) }
    association :user, factory: [:user, :seller]


    trait :low_stock do
      quantity { 1 }
    end

    trait :out_of_stock do
      quantity { 0 }
    end
end
end