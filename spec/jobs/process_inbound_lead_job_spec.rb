require "rails_helper"

RSpec.describe ProcessInboundLeadJob, type: :job do
  let(:inbound_lead) { create(:inbound_lead) }

  describe "#perform" do
    it "creates a Lead from the Angi payload" do
      expect { described_class.perform_now(inbound_lead) }
        .to change(Lead, :count).by(1)

      lead = Lead.last
      expect(lead.first_name).to eq("Jane")
      expect(lead.last_name).to eq("Doe")
      expect(lead.email).to eq("janedoe@gmail.com")
      expect(lead.phone).to eq("3031234567")
      expect(lead.address_street).to eq("123 Main Street")
      expect(lead.address_city).to eq("Denver")
      expect(lead.address_state).to eq("CO")
      expect(lead.address_zip).to eq("80210")
      expect(lead.source).to eq("Angi")
      expect(lead.lead_external_source).to eq("angi")
      expect(lead.lead_external_source_id).to eq(inbound_lead.external_id)
    end

    it "builds a message from taskName, comments, and interview Q&A" do
      described_class.perform_now(inbound_lead)

      lead = Lead.last
      expect(lead.message).to include("Service: Cabinet Refacing")
      expect(lead.message).to include("Looking for kitchen cabinet refacing")
      expect(lead.message).to include("Q: What type of project?")
      expect(lead.message).to include("A: Kitchen cabinets")
    end

    it "marks the InboundLead as processed and links to the Lead" do
      described_class.perform_now(inbound_lead)

      inbound_lead.reload
      expect(inbound_lead.status).to eq("processed")
      expect(inbound_lead.lead).to eq(Lead.last)
      expect(inbound_lead.processed_at).to be_within(2.seconds).of(Time.current)
    end

    context "when a Lead with the same external source + ID already exists" do
      it "links the InboundLead to the existing Lead without creating a new one" do
        existing = create(:lead, lead_external_source: "angi")
        existing.update_column(:lead_external_source_id, inbound_lead.external_id)

        expect { described_class.perform_now(inbound_lead) }
          .not_to change(Lead, :count)

        inbound_lead.reload
        expect(inbound_lead.status).to eq("processed")
        expect(inbound_lead.lead).to eq(existing)
      end
    end

    it "skips already-processed InboundLeads" do
      lead = create(:lead)
      inbound_lead.mark_processed!(lead)

      expect { described_class.perform_now(inbound_lead) }
        .not_to change(Lead, :count)
    end

    it "retries on error without immediately marking failed" do
      allow(Lead).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)

      described_class.perform_now(inbound_lead)

      expect(inbound_lead.reload.status).to eq("pending")
    end

    context "when firstName/lastName are missing" do
      let(:inbound_lead) do
        create(:inbound_lead, payload: {
          "name" => "John Smith",
          "email" => "test@example.com",
          "primaryPhone" => "5551234567",
          "taskName" => "Cabinet Refacing"
        })
      end

      it "falls back to splitting the name field" do
        described_class.perform_now(inbound_lead)

        lead = Lead.last
        expect(lead.first_name).to eq("John")
        expect(lead.last_name).to eq("Smith")
      end
    end

    context "when interview is not present" do
      let(:inbound_lead) do
        create(:inbound_lead, payload: {
          "firstName" => "Jane",
          "lastName" => "Doe",
          "email" => "jane@example.com",
          "primaryPhone" => "5551234567",
          "taskName" => "Cabinet Refacing",
          "comments" => "Need help"
        })
      end

      it "builds a message without Q&A" do
        described_class.perform_now(inbound_lead)

        lead = Lead.last
        expect(lead.message).to eq("Service: Cabinet Refacing\n\nNeed help")
        expect(lead.message).not_to include("Q:")
      end
    end
  end
end
