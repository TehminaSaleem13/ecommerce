FactoryBot.define do
    factory :coupon do
      code { "TEST10" }
      discount { 0.1 } # 10% discount
  
      trait :twenty_percent do
        code { "TEST20" }
        discount { 0.2 }
      end
    end
  end