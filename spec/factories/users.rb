
# FactoryBot.define do
#     factory :user do
#       first_name { "John" }
#       last_name { "Doe" }
#       sequence(:email) { |n| "user#{n}@example.com" }
#       password { "password90" }
#       password_confirmation { "password90" }
#       role { :seller }
#     end
#   end
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :buyer }
    
    trait :seller do
      role { :seller }
    end
    
   
  end
end