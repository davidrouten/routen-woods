FactoryBot.define do
  factory :note do
    association :notable, factory: :lead
    user
    body { "Follow up scheduled for next week." }
    note_type { "manual" }
  end
end
