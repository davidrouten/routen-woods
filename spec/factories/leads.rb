FactoryBot.define do
  factory :lead do
    first_name { "Jane" }
    last_name { "Smith" }
    email { Faker::Internet.unique.email }
    phone { "813-555-0100" }
    services_interested_in { ["cabinet_refacing"] }
    message { "I need my cabinets refaced" }
    source { "website" }
    status { :incoming }

    trait :spam do
      honeypot_value { "gotcha" }
    end

    trait :hot do
      lead_temperature { "hot" }
      ai_score { 80 }
    end

    trait :contacted do
      status { :contacted }
    end
  end
end
