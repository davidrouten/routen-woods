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
    it { is_expected.to belong_to(:customer).optional }
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

    it "does not create a status change when status is the same" do
      lead.transition_to!(:contacted, user: user)
      expect { lead.transition_to!(:contacted, user: user) }
        .not_to change { lead.status_changes.count }
    end

    it "does not update the record when status is the same" do
      lead.transition_to!(:contacted, user: user)
      expect { lead.transition_to!(:contacted, user: user) }
        .not_to change { lead.reload.updated_at }
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

  describe "#auto_detected_spam?" do
    it "returns true for auto-detected spam (score >= threshold)" do
      lead = create(:lead, :spam)
      expect(lead.auto_detected_spam?).to be true
    end

    it "returns false for manually-marked spam" do
      lead = create(:lead)
      lead.update_columns(spam: true)
      expect(lead.auto_detected_spam?).to be false
    end

    it "returns false for non-spam leads" do
      lead = create(:lead)
      expect(lead.auto_detected_spam?).to be false
    end
  end

  describe "#customer_will_be_deleted?" do
    it "returns true when auto-detected spam and customer has no other non-spam leads" do
      customer = create(:customer)
      lead = create(:lead, :spam, customer: customer)
      expect(lead.customer_will_be_deleted?).to be true
    end

    it "returns false when customer has other non-spam leads" do
      customer = create(:customer)
      lead = create(:lead, :spam, customer: customer)
      create(:lead, customer: customer)
      expect(lead.customer_will_be_deleted?).to be false
    end

    it "returns false for manually-marked spam even with orphaned customer" do
      customer = create(:customer)
      lead = create(:lead, customer: customer)
      lead.update_columns(spam: true)
      expect(lead.customer_will_be_deleted?).to be false
    end

    it "returns false when lead has no customer" do
      lead = create(:lead, :spam)
      expect(lead.customer_will_be_deleted?).to be false
    end
  end

  describe "customer linking" do
    it "auto-creates and links a customer on creation" do
      lead = create(:lead, email: "newcustomer@example.com")
      expect(lead.reload.customer).to be_present
      expect(lead.customer.email).to eq("newcustomer@example.com")
    end

    it "links to an existing customer with the same email" do
      existing = create(:customer, email: "returning@example.com")
      lead = create(:lead, email: "returning@example.com")

      expect(lead.reload.customer).to eq(existing)
    end

    it "does not link spam leads to a customer" do
      lead = create(:lead, :spam)
      expect(lead.reload.customer_id).to be_nil
    end

    it "does not create a customer when lead has no email or phone" do
      lead = build(:lead, email: nil, phone: nil)
      lead.save(validate: false)

      expect(lead.reload.customer_id).to be_nil
    end
  end
end
