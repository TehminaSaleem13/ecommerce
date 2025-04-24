# FactoryBot.define do
#     factory :cart do
#       association :user, factory: :user
      
#       trait :with_session_id do
#         user { nil }
#         sequence(:session_id) { |n| "session_#{n}" }
#       end
      
#       trait :with_coupon do
#         coupon_code { "DISCOUNT10" }
#         discount_percentage { 10 }
#       end
#     end
#   end

FactoryBot.define do
    factory :cart do
      association :user
      coupon_code { nil }
      discount_amount { 0.0 }
      
      trait :with_session_id do
                user { nil }
                sequence(:session_id) { |n| "session_#{n}" }
              end
      trait :with_items do
        after(:create) do |cart|
          create_list(:cart_item, 2, cart: cart)
        end
      end
      
      trait :with_discount do
        coupon_code { "DISCOUNT20" }
        discount_amount { 0.2 }
      end
    end
  end