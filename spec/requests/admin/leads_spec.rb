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

      it "sorts by name ascending" do
        create(:lead, first_name: "Zara", email: "z@example.com")
        create(:lead, first_name: "Alice", email: "a@example.com")
        get admin_leads_path, params: { sort: "name" }
        expect(response).to have_http_status(:ok)
        expect(response.body.index("Alice")).to be < response.body.index("Zara")
      end

      it "sorts by name descending" do
        create(:lead, first_name: "Zara", email: "z@example.com")
        create(:lead, first_name: "Alice", email: "a@example.com")
        get admin_leads_path, params: { sort: "-name" }
        expect(response).to have_http_status(:ok)
        expect(response.body.index("Zara")).to be < response.body.index("Alice")
      end

      it "sorts by city" do
        create(:lead, first_name: "A", email: "a@example.com", address_city: "Zebra Town")
        create(:lead, first_name: "B", email: "b@example.com", address_city: "Alphaville")
        get admin_leads_path, params: { sort: "city" }
        expect(response).to have_http_status(:ok)
      end

      it "sorts by date descending" do
        create(:lead, first_name: "Old", email: "old@example.com", created_at: 2.days.ago)
        create(:lead, first_name: "New", email: "new@example.com", created_at: 1.hour.ago)
        get admin_leads_path, params: { sort: "-date" }
        expect(response).to have_http_status(:ok)
        expect(response.body.index("New")).to be < response.body.index("Old")
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

  describe "GET /admin/leads/:id/edit" do
    let(:lead) { create(:lead) }
    before { sign_in admin }

    it "renders the edit form" do
      get edit_admin_lead_path(lead)
      expect(response).to be_successful
    end

    context "when not authenticated" do
      before { sign_out admin }

      it "redirects to login" do
        get edit_admin_lead_path(lead)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /admin/leads/:id" do
    let(:lead) { create(:lead, first_name: "Jane") }
    before { sign_in admin }

    it "updates the lead" do
      patch admin_lead_path(lead), params: {
        lead: {
          first_name: "Janet",
          lead_source: "Angi",
          lead_source_reference: "ANG-12345",
          other_service: "Custom pantry",
          address_street: "123 Main St",
          address_city: "Oxford",
          address_state: "MI",
          address_zip: "48371"
        }
      }
      lead.reload
      expect(lead.first_name).to eq("Janet")
      expect(lead.lead_source).to eq("Angi")
      expect(lead.lead_source_reference).to eq("ANG-12345")
      expect(lead.other_service).to eq("Custom pantry")
      expect(lead.address_street).to eq("123 Main St")
      expect(lead.address_city).to eq("Oxford")
      expect(response).to redirect_to(admin_lead_path(lead))
    end

    it "re-renders form on validation error" do
      patch admin_lead_path(lead), params: { lead: { first_name: "", email: "", phone: "" } }
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
