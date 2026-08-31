require "rails_helper"

RSpec.describe "Admin::Analytics", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:member) { create(:user) }

  describe "GET /admin/analytics" do
    context "when authenticated as admin" do
      before { sign_in admin }

      it "renders the analytics dashboard" do
        get admin_analytics_path
        expect(response).to have_http_status(:ok)
      end

      it "defaults to the current month" do
        get admin_analytics_path
        expect(response.body).to include(Date.current.strftime("%B %Y"))
      end

      it "accepts a month parameter" do
        get admin_analytics_path, params: { month: "2026-07" }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("July 2026")
      end

      it "displays visit and pageview stats" do
        get admin_analytics_path
        expect(response.body).to include("Total Visits")
        expect(response.body).to include("Unique Visitors")
        expect(response.body).to include("Page Views")
      end

      it "displays data sections" do
        get admin_analytics_path
        expect(response.body).to include("Traffic")
        expect(response.body).to include("Top Pages")
        expect(response.body).to include("Browsers")
      end

      it "shows visits for the selected month" do
        Ahoy::Visit.create!(visit_token: "a", visitor_token: "v1", started_at: Date.new(2026, 7, 15).noon)
        Ahoy::Visit.create!(visit_token: "b", visitor_token: "v2", started_at: Date.new(2026, 8, 10).noon)

        get admin_analytics_path, params: { month: "2026-07" }
        expect(response.body).to include("Total Visits")
      end

      it "groups visits by the application timezone, not UTC" do
        cst_late = Time.zone.parse("2026-08-31 23:30")
        Ahoy::Visit.create!(visit_token: "tz1", visitor_token: "v1", started_at: cst_late)

        get admin_analytics_path, params: { month: "2026-08" }
        doc = Nokogiri::HTML(response.body)
        total_visits = doc.css(".text-3xl").first.text.strip
        expect(total_visits).to eq("1")

        get admin_analytics_path, params: { month: "2026-09" }
        doc = Nokogiri::HTML(response.body)
        total_visits = doc.css(".text-3xl").first.text.strip
        expect(total_visits).to eq("0")
      end

      it "handles invalid month param gracefully" do
        get admin_analytics_path, params: { month: "garbage" }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(Date.current.strftime("%B %Y"))
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get admin_analytics_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated without permissions" do
      before { sign_in member }

      it "redirects to root" do
        get admin_analytics_path
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
