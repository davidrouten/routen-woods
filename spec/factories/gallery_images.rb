FactoryBot.define do
  factory :gallery_image do
    title { "Kitchen Remodel" }
    sequence(:position) { |n| n }
  end
end
