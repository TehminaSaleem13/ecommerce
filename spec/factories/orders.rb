FactoryBot.define do
    factory :order do
      association :user
      status { "pending" }
      total_price { 29.99 }
      subtotal { 29.99 }
      
      trait :paid do
        status { "paid" }
      end
      
      trait :failed do
        status { "failed" }
      end
      
      trait :with_discount do
        discount_amount { 3.00 }
        discount_percentage { 10 }
        coupon_code { "DISCOUNT10" }
      end
    end
  end