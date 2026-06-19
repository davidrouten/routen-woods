FactoryBot.define do
  factory :testimonial do
    author_name { "Sarah Johnson" }
    body { "Great work on our cabinets!" }
    rating { 5 }
    featured { false }
    position { 0 }
  end
end
