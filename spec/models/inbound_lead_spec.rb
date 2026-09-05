require "rails_helper"

RSpec.describe InboundLead, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:source) }
    it { is_expected.to validate_presence_of(:payload) }

    it "enforces unique external_id per source" do
      create(:inbound_lead, source: "angi", external_id: "123")
      dupe = build(:inbound_lead, source: "angi", external_id: "123")
      expect(dupe).not_to be_valid
      expect(dupe.errors[:external_id]).to include("has already been taken")
    end

    it "allows nil external_id" do
      create(:inbound_lead, external_id: nil)
      second = build(:inbound_lead, external_id: nil)
      expect(second).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:lead).optional }
  end

  describe "scopes" do
    let!(:pending_lead) { create(:inbound_lead, status: "pending") }
    let!(:processed_lead) { create(:inbound_lead, status: "processed") }
    let!(:failed_lead) { create(:inbound_lead, status: "failed") }

    it ".pending returns only pending records" do
      expect(described_class.pending).to eq([pending_lead])
    end

    it ".processed returns only processed records" do
      expect(described_class.processed).to eq([processed_lead])
    end

    it ".failed returns only failed records" do
      expect(described_class.failed).to eq([failed_lead])
    end
  end

  describe "#mark_processed!" do
    it "updates status, lead, and processed_at" do
      inbound = create(:inbound_lead)
      lead = create(:lead)

      inbound.mark_processed!(lead)

      expect(inbound.status).to eq("processed")
      expect(inbound.lead).to eq(lead)
      expect(inbound.processed_at).to be_within(1.second).of(Time.current)
    end
  end

  describe "#mark_failed!" do
    it "updates status to failed" do
      inbound = create(:inbound_lead)
      inbound.mark_failed!
      expect(inbound.status).to eq("failed")
    end
  end
end
