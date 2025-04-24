FactoryBot.define do
    factory :review do
      association :user
      association :product
      text { "This is a great product. I highly recommend it!" }
    end
  end