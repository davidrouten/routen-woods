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

  describe "GET /admin/leads/new" do
    before { sign_in admin }

    it "renders the new lead form" do
      get new_admin_lead_path
      expect(response).to be_successful
    end
  end

  describe "POST /admin/leads" do
    before { sign_in admin }

    it "creates a lead" do
      expect {
        post admin_leads_path, params: {
          lead: {
            first_name: "Jane",
            last_name: "Doe",
            email: "jane@example.com",
            phone: "555-1234",
            budget_range: "10_15k",
            timeframe: "within_month",
            zip_code: "90210",
            services_interested_in: ["refacing", "countertops"],
            message: "Interested in a kitchen remodel"
          }
        }
      }.to change(Lead, :count).by(1)

      lead = Lead.last
      expect(lead.first_name).to eq("Jane")
      expect(lead.budget_range).to eq("10_15k")
      expect(lead.services_interested_in).to eq(["refacing", "countertops"])
      expect(response).to redirect_to(admin_lead_path(lead))
    end

    it "re-renders form on validation error" do
      post admin_leads_path, params: { lead: { first_name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
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
