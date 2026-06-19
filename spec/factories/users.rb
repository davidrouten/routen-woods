FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name { "Doe" }
    email { Faker::Internet.unique.email }
    password { "password123" }
    admin { false }

    trait :admin do
      admin { true }
    end
  end
end
