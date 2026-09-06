require "rails_helper"

RSpec.describe Attachment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:uploaded_by).class_name("User") }
  end

  describe "validations" do
    it "requires a file" do
      attachment = Attachment.new(project: create(:project), uploaded_by: create(:user))
      expect(attachment).not_to be_valid
      expect(attachment.errors[:file]).to include("can't be blank")
    end

    it "is valid with a file" do
      attachment = build(:attachment)
      expect(attachment).to be_valid
    end
  end

  describe "#filename" do
    it "returns the attached filename" do
      attachment = create(:attachment)
      expect(attachment.filename).to eq("test-document.pdf")
    end
  end

  describe "#image?" do
    it "returns true for image content types" do
      attachment = build(:attachment, :image)
      expect(attachment).to be_image
    end

    it "returns false for non-image content types" do
      attachment = build(:attachment)
      expect(attachment).not_to be_image
    end
  end

  describe "#file_size" do
    it "returns the byte size" do
      attachment = create(:attachment)
      expect(attachment.file_size).to be > 0
    end
  end

  describe "scopes" do
    it ".recent orders by created_at desc" do
      project = create(:project)
      user = create(:user)
      old = create(:attachment, project: project, uploaded_by: user, created_at: 2.days.ago)
      recent = create(:attachment, project: project, uploaded_by: user, created_at: 1.hour.ago)
      expect(Attachment.recent).to eq([recent, old])
    end
  end
end
