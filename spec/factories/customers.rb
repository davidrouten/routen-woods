FactoryBot.define do
  factory :customer do
    first_name { "Jane" }
    last_name { "Smith" }
    email { Faker::Internet.unique.email }
    phone { "813-555-0100" }
  end
end
