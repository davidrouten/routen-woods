require "rails_helper"

RSpec.describe LeadScorer do
  describe "#score!" do
    it "scores a complete lead as hot" do
      lead = create(:lead,
        email: "jane@example.com",
        phone: "813-555-0100",
        last_name: "Smith",
        message: "I need my kitchen cabinets completely refaced with new doors",
        service_interested_in: "cabinet_refacing"
      )
      expect(lead.reload.lead_temperature).to eq("hot")
      expect(lead.ai_score).to be >= 70
    end

    it "scores a minimal lead as cold" do
      lead = create(:lead,
        email: "x@y.com",
        phone: nil,
        last_name: nil,
        message: nil,
        service_interested_in: nil
      )
      expect(lead.reload.lead_temperature).to eq("cold")
      expect(lead.ai_score).to be < 40
    end

    it "gives bonus points for high-value services" do
      lead_high = create(:lead, service_interested_in: "cabinet_refacing")
      lead_low = create(:lead, service_interested_in: "other_service")
      expect(lead_high.reload.ai_score).to be > lead_low.reload.ai_score
    end
  end
end
