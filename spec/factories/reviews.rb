FactoryBot.define do
  factory :review do
    association :user
    association :product
    text { Faker::Lorem.paragraph }
  end
end