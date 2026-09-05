FactoryBot.define do
  factory :project do
    association :lead
    title { "Cabinet Refacing — Jane Smith" }
    description { "Full kitchen refacing with shaker doors" }
    email { "jane@example.com" }
    phone { "813-555-0100" }
    address { "123 Main St, Oxford MI 48371" }
    status { :scheduled }
    estimated_price { 7500.00 }
    agreed_price { 7000.00 }
    deposit_amount { 2000.00 }
    balance_amount { 5000.00 }
    time_estimate { "4-5 days" }
    scheduled_start_date { 1.week.from_now.to_date }
    estimated_duration_days { 5.0 }
    work_saturdays { false }
    calendar_color { nil }

    trait :in_progress do
      status { :in_progress }
      started_at { 2.days.ago }
    end

    trait :complete do
      status { :complete }
      completed_at { 1.day.ago }
    end

    trait :paid do
      status { :paid }
      paid_at { Time.current }
    end
  end
end
