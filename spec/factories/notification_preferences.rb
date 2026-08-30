FactoryBot.define do
  factory :notification_preference do
    user
    event_name { "new_lead" }
    email_enabled { true }
    sms_enabled { false }
    slack_enabled { true }
  end
end
