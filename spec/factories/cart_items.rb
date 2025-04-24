# FactoryBot.define do
#     factory :cart_item do
#       association :cart
#       association :product
#       quantity { 1 }
#       price { product.price }
      
#       trait :higher_quantity do
#         quantity { 3 }
#       end
#     end
#   end

  FactoryBot.define do
    factory :cart_item do
      association :cart
      association :product
      quantity { 1 }
      
      trait :with_order do
        association :order
      end
    end
  end