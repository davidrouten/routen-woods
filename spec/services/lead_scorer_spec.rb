require "rails_helper"

RSpec.describe LeadScorer do
  describe "#score!" do
    it "scores a complete lead as hot" do
      lead = create(:lead,
        email: "jane@example.com",
        phone: "813-555-0100",
        last_name: "Smith",
        message: "I need my kitchen cabinets completely refaced with new doors",
        services_interested_in: ["cabinet_refacing"],
        budget_range: "10_15k",
        timeframe: "asap"
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
        services_interested_in: [],
        budget_range: nil,
        timeframe: nil
      )
      expect(lead.reload.lead_temperature).to eq("cold")
      expect(lead.ai_score).to be < 40
    end

    it "gives bonus points for high-value services" do
      lead_high = create(:lead, services_interested_in: ["cabinet_refacing"])
      lead_low = create(:lead, services_interested_in: ["other_service"])
      expect(lead_high.reload.ai_score).to be > lead_low.reload.ai_score
    end

    it "scores higher budgets with more points" do
      lead_high = create(:lead, budget_range: "20k_plus")
      lead_low = create(:lead, budget_range: "under_5k")
      expect(lead_high.reload.ai_score).to be > lead_low.reload.ai_score
    end

    it "scores urgent timeframes with more points" do
      lead_asap = create(:lead, timeframe: "asap")
      lead_planning = create(:lead, timeframe: "planning")
      expect(lead_asap.reload.ai_score).to be > lead_planning.reload.ai_score
    end
  end
end
