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

      it "defaults to 30d period" do
        get admin_analytics_path
        expect(response.body).to include("30d")
      end

      it "accepts a period parameter" do
        get admin_analytics_path, params: { period: "7d" }
        expect(response).to have_http_status(:ok)
      end

      it "displays visit and pageview stats" do
        get admin_analytics_path
        expect(response.body).to include("Total Visits")
        expect(response.body).to include("Unique Visitors")
        expect(response.body).to include("Page Views")
      end

      it "displays data sections" do
        get admin_analytics_path
        expect(response.body).to include("Visits by Day")
        expect(response.body).to include("Top Pages")
        expect(response.body).to include("Browsers")
      end

      it "counts visits in the selected period" do
        Ahoy::Visit.create!(visit_token: "a", visitor_token: "v1", started_at: 2.days.ago)
        Ahoy::Visit.create!(visit_token: "b", visitor_token: "v2", started_at: 60.days.ago)

        get admin_analytics_path, params: { period: "30d" }
        expect(response.body).to include("Total Visits")
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
