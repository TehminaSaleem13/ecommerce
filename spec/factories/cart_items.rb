
FactoryBot.define do
  factory :cart_item do
    association :cart
    association :product
    quantity { 1 }
    price { product.price }

    trait :with_order do
      association :order
    end
  end
end