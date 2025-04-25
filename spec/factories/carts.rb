

FactoryBot.define do
  factory :cart do
    association :user, factory: :user
    discount_amount { 0.0 }
    coupon_code { nil }
    session_id { SecureRandom.uuid } 

    trait :with_items do
      after(:create) do |cart|
        create_list(:cart_item, 2, cart: cart)
      end
    end

    trait :with_discount do
      discount_amount { 0.1 } 
      coupon_code { "TEST10" }
    end

    trait :guest_cart do
      user { nil }
      session_id { SecureRandom.uuid }
    end
  end
end
