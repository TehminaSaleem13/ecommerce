FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    role { :buyer }

    trait :seller do
      role { :seller }
    end

    trait :buyer do
      role { :buyer }
    end

   
  end
end