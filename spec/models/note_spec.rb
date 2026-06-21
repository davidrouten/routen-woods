require "rails_helper"

RSpec.describe Note, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:body) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:notable) }
    it { is_expected.to belong_to(:user) }
  end

  describe "scopes" do
    let(:lead) { create(:lead) }
    let(:user) { create(:user) }

    it ".chronological orders by created_at asc" do
      old = create(:note, notable: lead, user: user, created_at: 1.day.ago)
      recent = create(:note, notable: lead, user: user, created_at: Time.current)
      expect(Note.chronological).to eq([old, recent])
    end
  end
end
