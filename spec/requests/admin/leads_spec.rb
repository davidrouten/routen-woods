require "rails_helper"

RSpec.describe "Admin::Leads", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:member) { create(:user) }

  describe "GET /admin/leads" do
    context "when authenticated as admin" do
      before { sign_in admin }

      it "renders the leads index" do
        create(:lead)
        get admin_leads_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get admin_leads_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated without permissions" do
      before { sign_in member }

      it "redirects to root" do
        get admin_leads_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /admin/leads/:id/transition" do
    let(:lead) { create(:lead, status: :incoming) }

    before { sign_in admin }

    it "transitions the lead status" do
      patch transition_admin_lead_path(lead), params: { status: "contacted" }
      expect(lead.reload.status).to eq("contacted")
    end
  end

  describe "PATCH /admin/leads/:id/mark_spam" do
    let(:lead) { create(:lead, spam: false) }

    before { sign_in admin }

    it "marks the lead as spam" do
      patch mark_spam_admin_lead_path(lead)
      expect(lead.reload.spam).to be true
    end
  end
end
