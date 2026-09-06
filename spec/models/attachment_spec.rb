require "rails_helper"

RSpec.describe Attachment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:attachable) }
    it { is_expected.to belong_to(:uploaded_by).class_name("User") }
  end

  describe "validations" do
    it "requires a file" do
      attachment = Attachment.new(attachable: create(:project), uploaded_by: create(:user))
      expect(attachment).not_to be_valid
      expect(attachment.errors[:file]).to include("can't be blank")
    end

    it "is valid with a file" do
      attachment = build(:attachment)
      expect(attachment).to be_valid
    end
  end

  describe "polymorphic attachable" do
    it "can belong to a project" do
      attachment = create(:attachment)
      expect(attachment.attachable).to be_a(Project)
    end

    it "can belong to an invoice" do
      attachment = create(:attachment, :on_invoice)
      expect(attachment.attachable).to be_a(Invoice)
    end

    it "can belong to an order form" do
      attachment = create(:attachment, :on_order_form)
      expect(attachment.attachable).to be_a(OrderForm)
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

  describe "#text?" do
    it "returns true for text/plain" do
      attachment = build(:attachment)
      attachment.file.attach(io: StringIO.new("hello"), filename: "notes.txt", content_type: "text/plain")
      expect(attachment).to be_text
    end

    it "returns true for text/markdown" do
      attachment = build(:attachment)
      attachment.file.attach(io: StringIO.new("# Hello"), filename: "readme.md", content_type: "text/markdown")
      expect(attachment).to be_text
    end

    it "returns false for application/rtf" do
      attachment = build(:attachment)
      attachment.file.attach(io: StringIO.new("rtf content"), filename: "doc.rtf", content_type: "application/rtf")
      expect(attachment).not_to be_text
    end

    it "returns false for PDFs" do
      attachment = build(:attachment)
      expect(attachment).not_to be_text
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
      old = create(:attachment, attachable: project, uploaded_by: user, created_at: 2.days.ago)
      recent = create(:attachment, attachable: project, uploaded_by: user, created_at: 1.hour.ago)
      expect(Attachment.recent).to eq([recent, old])
    end
  end
end
