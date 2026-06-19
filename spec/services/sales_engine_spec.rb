require "rails_helper"

RSpec.describe SalesEngine do
  describe ".create_lead" do
    it "creates a lead via the adapter" do
      lead = SalesEngine.create_lead(
        first_name: "Test",
        email: "test@example.com",
        service_interested_in: "cabinet_refinishing",
        source: "website"
      )
      expect(lead).to be_persisted
      expect(lead.first_name).to eq("Test")
    end
  end

  describe ".list_leads" do
    it "returns non-spam leads" do
      create(:lead, spam: false)
      create(:lead, :spam)
      leads = SalesEngine.list_leads
      expect(leads.count).to eq(1)
    end

    it "filters by status" do
      create(:lead, status: :incoming)
      create(:lead, status: :contacted)
      leads = SalesEngine.list_leads(filters: { status: :incoming })
      expect(leads.count).to eq(1)
    end
  end

  describe ".search" do
    it "finds leads by name" do
      create(:lead, first_name: "Alice")
      create(:lead, first_name: "Bob")
      results = SalesEngine.search("Alice")
      expect(results.count).to eq(1)
      expect(results.first.first_name).to eq("Alice")
    end
  end
end
