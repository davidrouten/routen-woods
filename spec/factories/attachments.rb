FactoryBot.define do
  factory :attachment do
    association :project
    association :uploaded_by, factory: :user

    after(:build) do |attachment|
      attachment.file.attach(
        io: StringIO.new("test file content"),
        filename: "test-document.pdf",
        content_type: "application/pdf"
      )
    end

    trait :image do
      after(:build) do |attachment|
        attachment.file.attach(
          io: StringIO.new("fake image data"),
          filename: "photo.jpg",
          content_type: "image/jpeg"
        )
      end
    end

    trait :with_description do
      description { "Signed contract scan" }
    end
  end
end
