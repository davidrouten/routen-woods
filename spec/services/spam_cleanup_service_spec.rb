require "rails_helper"

RSpec.describe SpamCleanupService do
  describe ".delete_lead" do
    it "destroys the lead" do
      lead = create(:lead, :spam)
      expect { described_class.delete_lead(lead) }.to change(Lead, :count).by(-1)
    end

    it "destroys associated notes and status changes" do
      lead = create(:lead, :spam)
      lead.notes.create!(body: "test", user: create(:user, :admin))
      lead.status_changes.create!(from_status: "incoming", to_status: "contacted", user: create(:user, :admin))

      expect { described_class.delete_lead(lead) }
        .to change(Note, :count).by(-1)
        .and change(StatusChange, :count).by(-1)
    end

    it "nullifies associated projects" do
      lead = create(:lead, :spam)
      project = create(:project, lead: lead)

      described_class.delete_lead(lead)
      expect(project.reload.lead_id).to be_nil
    end

    context "auto-detected spam lead with customer" do
      it "deletes the customer when they have no non-spam leads" do
        customer = create(:customer)
        lead = create(:lead, :spam, customer: customer)

        expect { described_class.delete_lead(lead) }.to change(Customer, :count).by(-1)
      end

      it "preserves the customer when they have non-spam leads" do
        customer = create(:customer)
        spam_lead = create(:lead, :spam, customer: customer)
        create(:lead, customer: customer)

        expect { described_class.delete_lead(spam_lead) }.not_to change(Customer, :count)
      end

      it "deletes the customer even when other spam leads reference them" do
        customer = create(:customer)
        lead1 = create(:lead, :spam, customer: customer)
        lead2 = create(:lead, :spam, customer: customer)

        described_class.delete_lead(lead1)
        expect(Customer.find_by(id: customer.id)).to be_nil
        expect(lead2.reload.customer_id).to be_nil
      end

    end

    context "manually-marked spam lead with customer" do
      it "does NOT delete the customer even when they have no other leads" do
        customer = create(:customer)
        lead = create(:lead, customer: customer)
        lead.update_columns(spam: true)

        expect(lead.spam_score).to be < SpamDetector::SPAM_THRESHOLD
        expect { described_class.delete_lead(lead) }.not_to change(Customer, :count)
      end
    end

    context "when the lead has no customer" do
      it "succeeds without errors" do
        lead = create(:lead, :spam)
        expect(lead.customer_id).to be_nil
        expect { described_class.delete_lead(lead) }.to change(Lead, :count).by(-1)
      end
    end
  end

  describe ".purge_all_spam" do
    it "deletes all spam leads including manually-marked ones" do
      create_list(:lead, 2, :spam)
      manually_marked = create(:lead)
      manually_marked.update_columns(spam: true)
      create(:lead)

      result = described_class.purge_all_spam
      expect(result[:leads_deleted]).to eq(3)
      expect(Lead.spam_only.count).to eq(0)
      expect(Lead.not_spam.count).to eq(1)
    end

    it "deletes orphaned customers from auto-detected spam leads" do
      customer = create(:customer)
      create(:lead, :spam, customer: customer)

      result = described_class.purge_all_spam
      expect(result[:customers_deleted]).to eq(1)
      expect(Customer.find_by(id: customer.id)).to be_nil
    end

    it "does NOT delete customers linked only to manually-marked spam leads" do
      customer = create(:customer)
      lead = create(:lead, customer: customer)
      lead.update_columns(spam: true)

      result = described_class.purge_all_spam
      expect(result[:leads_deleted]).to eq(1)
      expect(result[:customers_deleted]).to eq(0)
      expect(Customer.find_by(id: customer.id)).to be_present
    end

    it "preserves customers with non-spam leads" do
      customer = create(:customer)
      create(:lead, :spam, customer: customer)
      create(:lead, customer: customer)

      result = described_class.purge_all_spam
      expect(result[:customers_deleted]).to eq(0)
      expect(Customer.find_by(id: customer.id)).to be_present
    end

    it "returns zeroes when no spam leads exist" do
      create(:lead)
      result = described_class.purge_all_spam
      expect(result).to eq(leads_deleted: 0, customers_deleted: 0)
    end

    it "handles multiple auto-detected spam leads pointing to the same customer" do
      customer = create(:customer)
      create(:lead, :spam, customer: customer)
      create(:lead, :spam, customer: customer)

      result = described_class.purge_all_spam
      expect(result[:leads_deleted]).to eq(2)
      expect(result[:customers_deleted]).to eq(1)
    end

    it "cascades notes and status changes" do
      lead = create(:lead, :spam)
      lead.notes.create!(body: "spam note", user: create(:user, :admin))
      lead.status_changes.create!(from_status: "incoming", to_status: "contacted", user: create(:user, :admin))

      expect { described_class.purge_all_spam }
        .to change(Note, :count).by(-1)
        .and change(StatusChange, :count).by(-1)
    end
  end
end
