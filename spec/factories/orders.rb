FactoryBot.define do
  factory :order do
    association :user
    status { 'pending' }
    total_price { 100.0 }
    subtotal { 100.0 }
    discount_amount { 0.0 }
    discount_percentage { 0 }
    coupon_code { nil }

    trait :paid do
      status { 'paid' }
    end

    trait :failed do
      status { 'failed' }
    end

    trait :with_discount do
      discount_amount { 10.0 }
      discount_percentage { 10 }
      coupon_code { "TEST10" }
      total_price { 90.0 }
    end

    trait :with_items do
      after(:create) do |order|
        create_list(:cart_item, 2, order: order)
      end
    end
  end
end