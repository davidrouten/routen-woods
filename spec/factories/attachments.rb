FactoryBot.define do
  factory :attachment do
    association :attachable, factory: :project
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

    trait :on_invoice do
      association :attachable, factory: :invoice
    end

    trait :on_order_form do
      association :attachable, factory: :order_form
    end

    trait :with_description do
      description { "Signed contract scan" }
    end
  end
end
