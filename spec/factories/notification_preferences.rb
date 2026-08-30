FactoryBot.define do
  factory :notification_preference do
    user
    preferences { NotificationPreference.default_preferences }
  end
end
