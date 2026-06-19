FactoryBot.define do
  factory :permission do
    resource { "leads" }
    action { "view" }
  end
end
