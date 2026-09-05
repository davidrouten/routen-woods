require "rails_helper"

RSpec.describe "Webhooks::Angi", type: :request do
  let(:api_key) { "test-angi-api-key-123" }
  let(:headers) do
    {
      "Content-Type" => "application/json",
      "x-api-key" => api_key
    }
  end

  let(:angi_payload) do
    {
      name: "Jane Doe",
      firstName: "Jane",
      lastName: "Doe",
      address: "123 Oak St",
      city: "Oxford",
      stateProvince: "MI",
      postalCode: "48371",
      primaryPhone: "248-555-1234",
      email: "jane@example.com",
      srOid: 987_654,
      leadOid: 123_456,
      fee: 29.99,
      taskName: "Cabinet Refacing",
      comments: "Looking for kitchen cabinet refacing",
      matchType: "Direct Match",
      leadDescription: "Service Request",
      spCompanyName: "Routen Woods",
      automatedContactCompliant: true,
      interview: [
        { question: "What type of project?", answer: "Kitchen cabinets" }
      ]
    }
  end

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("ANGI_WEBHOOK_API_KEY").and_return(api_key)
  end

  describe "POST /webhooks/angi" do
    it "saves the lead and returns success" do
      expect {
        post "/webhooks/angi", params: angi_payload.to_json, headers: headers
      }.to change(InboundLead, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("status" => "success")

      inbound = InboundLead.last
      expect(inbound.source).to eq("angi")
      expect(inbound.external_id).to eq("123456")
      expect(inbound.status).to eq("pending")
      expect(inbound.payload["firstName"]).to eq("Jane")
      expect(inbound.payload["taskName"]).to eq("Cabinet Refacing")
      expect(inbound.payload["interview"]).to be_an(Array)
    end

    it "rejects requests with wrong API key" do
      post "/webhooks/angi",
        params: angi_payload.to_json,
        headers: headers.merge("x-api-key" => "wrong-key")

      expect(response).to have_http_status(:unauthorized)
      expect(InboundLead.count).to eq(0)
    end

    it "rejects requests with no API key" do
      post "/webhooks/angi",
        params: angi_payload.to_json,
        headers: headers.except("x-api-key")

      expect(response).to have_http_status(:unauthorized)
      expect(InboundLead.count).to eq(0)
    end

    it "handles duplicate leadOid gracefully" do
      post "/webhooks/angi", params: angi_payload.to_json, headers: headers
      expect(InboundLead.count).to eq(1)

      post "/webhooks/angi", params: angi_payload.to_json, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("status" => "success")
      expect(InboundLead.count).to eq(1)
    end

    it "stores the full payload as JSON" do
      post "/webhooks/angi", params: angi_payload.to_json, headers: headers

      payload = InboundLead.last.payload
      expect(payload["primaryPhone"]).to eq("248-555-1234")
      expect(payload["address"]).to eq("123 Oak St")
      expect(payload["fee"]).to eq(29.99)
      expect(payload["automatedContactCompliant"]).to be(true)
    end

    it "returns 503 when no API key is configured" do
      allow(ENV).to receive(:[]).with("ANGI_WEBHOOK_API_KEY").and_return(nil)
      allow(Rails.application.credentials).to receive(:dig).with(:angi, :api_key).and_return(nil)

      post "/webhooks/angi", params: angi_payload.to_json, headers: headers

      expect(response).to have_http_status(:service_unavailable)
    end
  end
end
