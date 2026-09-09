require "rails_helper"

RSpec.describe InboundLeadMappers::Angi do
  let(:inbound_lead) { create(:inbound_lead) }
  subject(:attrs) { described_class.new(inbound_lead).to_lead_attributes }

  it "maps contact fields" do
    expect(attrs[:first_name]).to eq("Jane")
    expect(attrs[:last_name]).to eq("Doe")
    expect(attrs[:email]).to eq("janedoe@gmail.com")
    expect(attrs[:phone]).to eq("3031234567")
  end

  it "maps address fields" do
    expect(attrs[:address_street]).to eq("123 Main Street")
    expect(attrs[:address_city]).to eq("Denver")
    expect(attrs[:address_state]).to eq("CO")
    expect(attrs[:address_zip]).to eq("80210")
  end

  it "sets Angi as source with external ID" do
    expect(attrs[:source]).to eq("Angi")
    expect(attrs[:lead_external_source]).to eq("angi")
    expect(attrs[:lead_external_source_id]).to eq(inbound_lead.external_id)
  end

  it "builds message from taskName, comments, and interview" do
    expect(attrs[:message]).to include("Service: Cabinet Refacing")
    expect(attrs[:message]).to include("Looking for kitchen cabinet refacing")
    expect(attrs[:message]).to include("Q: What type of project?")
    expect(attrs[:message]).to include("A: Kitchen cabinets")
  end

  context "when firstName/lastName are blank" do
    let(:inbound_lead) do
      create(:inbound_lead, payload: {
        "name" => "John Smith",
        "email" => "test@example.com",
        "primaryPhone" => "5551234567"
      })
    end

    it "falls back to splitting name field" do
      expect(attrs[:first_name]).to eq("John")
      expect(attrs[:last_name]).to eq("Smith")
    end
  end

  context "with minimal payload" do
    let(:inbound_lead) do
      create(:inbound_lead, payload: {
        "firstName" => "Jane",
        "email" => "jane@example.com"
      })
    end

    it "handles missing optional fields" do
      expect(attrs[:phone]).to be_nil
      expect(attrs[:address_street]).to be_nil
      expect(attrs[:message]).to eq("")
    end
  end
end
