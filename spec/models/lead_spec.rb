require "rails_helper"

RSpec.describe Lead, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }

    it "requires email when phone is blank" do
      lead = build(:lead, email: nil, phone: nil)
      expect(lead).not_to be_valid
      expect(lead.errors[:email]).to be_present
    end

    it "allows blank email when phone is present" do
      lead = build(:lead, email: nil, phone: "813-555-0100")
      expect(lead).to be_valid
    end

    it "allows blank phone when email is present" do
      lead = build(:lead, phone: nil, email: "test@example.com")
      expect(lead).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:assigned_to).optional }
    it { is_expected.to have_many(:notes).dependent(:destroy) }
    it { is_expected.to have_many(:status_changes).dependent(:destroy) }
  end

  describe "scopes" do
    before do
      spam_lead = create(:lead)
      spam_lead.update_columns(spam: true)
      create(:lead)
    end

    it ".not_spam excludes spam leads" do
      expect(Lead.not_spam.count).to eq(1)
    end

    it ".spam_only returns only spam leads" do
      expect(Lead.spam_only.count).to eq(1)
    end
  end

  describe "#transition_to!" do
    let(:lead) { create(:lead, status: :incoming) }
    let(:user) { create(:user, :admin) }

    it "changes the lead status" do
      lead.transition_to!(:contacted, user: user)
      expect(lead.reload.status).to eq("contacted")
    end

    it "creates a status change record" do
      expect { lead.transition_to!(:contacted, user: user) }
        .to change { lead.status_changes.count }.by(1)
    end

    it "records the from and to status" do
      lead.transition_to!(:contacted, user: user)
      change = lead.status_changes.last
      expect(change.from_status).to eq("incoming")
      expect(change.to_status).to eq("contacted")
    end
  end

  describe "after_create callbacks" do
    it "calculates spam score on creation" do
      lead = create(:lead)
      expect(lead.spam_score).to be_a(Float)
    end

    it "calculates lead temperature on creation" do
      lead = create(:lead)
      expect(lead.lead_temperature).to be_in(%w[hot warm cold])
    end

    it "marks honeypot leads as spam" do
      lead = create(:lead, :spam)
      expect(lead.reload.spam).to be true
    end
  end
end
