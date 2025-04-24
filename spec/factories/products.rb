
FactoryBot.define do
  factory :product do
    association :user, factory: [:user, :seller]
    sequence(:title) { |n| "Product #{n}" }
    description { "A detailed product description" }
    price { 19.99 }
    quantity { 10 }
    
    
    
    trait :low_stock do
      quantity { 1 }
    end
    
    trait :out_of_stock do
      quantity { 0 }
    end
    trait :with_reviews do
      after(:create) do |product|
        create_list(:review, 3, product: product)
      end
    end
  end
end