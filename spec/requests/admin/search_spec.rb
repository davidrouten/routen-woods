require "rails_helper"

RSpec.describe "Admin::Search", type: :request do
  let(:admin) { create(:user, :admin) }

  before do
    allow_any_instance_of(Lead).to receive(:link_to_customer)
  end

  describe "GET /admin/search" do
    context "when authenticated" do
      before { sign_in admin }

      it "returns JSON results" do
        create(:lead, first_name: "Marcus")
        get admin_search_path, params: { q: "Marcus" }, headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")
        results = JSON.parse(response.body)
        expect(results.length).to eq(1)
        expect(results.first["title"]).to eq("Marcus Smith")
      end

      it "returns empty array for short queries" do
        get admin_search_path, params: { q: "M" }, headers: { "Accept" => "application/json" }
        expect(JSON.parse(response.body)).to eq([])
      end

      it "returns empty array for no matches" do
        get admin_search_path, params: { q: "zzzznonexistent" }, headers: { "Accept" => "application/json" }
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get admin_search_path, params: { q: "test" }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
