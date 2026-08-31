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

      it "shows active sort arrow on the default column without a sort param" do
        create(:lead)
        get admin_leads_path
        expect(response.body).to include("▼") # Date desc is the default
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

  describe "DELETE /admin/leads/:id" do
    before { sign_in admin }

    it "permanently deletes a spam lead" do
      lead = create(:lead, :spam)
      expect { delete admin_lead_path(lead) }.to change(Lead, :count).by(-1)
      expect(response).to redirect_to(admin_leads_path(spam: true))
    end

    it "permanently deletes a manually-marked spam lead" do
      lead = create(:lead)
      lead.update_columns(spam: true)
      expect { delete admin_lead_path(lead) }.to change(Lead, :count).by(-1)
    end

    it "removes the row via Turbo Stream" do
      lead = create(:lead, :spam)
      delete admin_lead_path(lead), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
    end

    it "deletes orphaned customer for auto-detected spam" do
      customer = create(:customer)
      lead = create(:lead, :spam, customer: customer)

      expect { delete admin_lead_path(lead) }.to change(Customer, :count).by(-1)
    end

    it "does NOT delete customer for manually-marked spam" do
      customer = create(:customer)
      lead = create(:lead, customer: customer)
      lead.update_columns(spam: true)

      expect { delete admin_lead_path(lead) }.not_to change(Customer, :count)
    end

    it "preserves customer with non-spam leads" do
      customer = create(:customer)
      lead = create(:lead, :spam, customer: customer)
      create(:lead, customer: customer)

      expect { delete admin_lead_path(lead) }.not_to change(Customer, :count)
    end

    context "when not authorized" do
      before { sign_in member }

      it "redirects" do
        lead = create(:lead, :spam)
        delete admin_lead_path(lead)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /admin/leads/purge_spam" do
    before { sign_in admin }

    it "deletes all spam leads including manually-marked ones" do
      create_list(:lead, 2, :spam)
      manually_marked = create(:lead)
      manually_marked.update_columns(spam: true)
      create(:lead)

      expect { delete purge_spam_admin_leads_path }.to change(Lead, :count).by(-3)
      expect(response).to redirect_to(admin_leads_path(spam: true))
      expect(flash[:notice]).to include("3 spam leads")
    end

    it "deletes orphaned customers from auto-detected spam" do
      customer = create(:customer)
      create(:lead, :spam, customer: customer)

      delete purge_spam_admin_leads_path
      expect(flash[:notice]).to include("1 orphaned customer")
      expect(Customer.find_by(id: customer.id)).to be_nil
    end

    it "does NOT delete customers from manually-marked spam" do
      customer = create(:customer)
      lead = create(:lead, customer: customer)
      lead.update_columns(spam: true)

      delete purge_spam_admin_leads_path
      expect(flash[:notice]).to include("0 orphaned customers")
      expect(Customer.find_by(id: customer.id)).to be_present
    end

    it "handles no spam leads gracefully" do
      delete purge_spam_admin_leads_path
      expect(response).to redirect_to(admin_leads_path(spam: true))
      expect(flash[:notice]).to include("0 spam leads")
    end

    context "when not authorized" do
      before { sign_in member }

      it "redirects" do
        delete purge_spam_admin_leads_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "confirm dialog content" do
    before { sign_in admin }

    context "spam index view" do
      it "shows customer name in delete button when customer will be deleted" do
        customer = create(:customer, first_name: "Bogus", last_name: "Spammer")
        create(:lead, :spam, customer: customer)

        get admin_leads_path(spam: true)
        expect(response.body).to include("Bogus Spammer")
        expect(response.body).to include("no other non-spam leads")
      end

      it "does NOT show customer warning for manually-marked spam" do
        customer = create(:customer, first_name: "Real", last_name: "Person")
        lead = create(:lead, customer: customer, first_name: "Suspicious", last_name: "Lead")
        lead.update_columns(spam: true)

        get admin_leads_path(spam: true)
        expect(response.body).not_to include("also permanently delete customer")
      end

      it "does NOT show customer warning when customer has other non-spam leads" do
        customer = create(:customer, first_name: "Shared", last_name: "Customer")
        create(:lead, :spam, customer: customer)
        create(:lead, customer: customer)

        get admin_leads_path(spam: true)
        expect(response.body).not_to include("also permanently delete customer")
      end

      it "shows Delete All Spam button with count" do
        create_list(:lead, 3, :spam)
        get admin_leads_path(spam: true)
        expect(response.body).to include("Delete All Spam")
        expect(response.body).to include("3 spam leads")
      end
    end

    context "spam lead show page" do
      it "shows customer name in delete confirmation when customer will be deleted" do
        customer = create(:customer, first_name: "Bogus", last_name: "Bot")
        lead = create(:lead, :spam, customer: customer)

        get admin_lead_path(lead)
        expect(response.body).to include("Bogus Bot")
        expect(response.body).to include("no other non-spam leads")
      end

      it "does NOT show customer warning for manually-marked spam" do
        customer = create(:customer, first_name: "Legit", last_name: "Customer")
        lead = create(:lead, customer: customer)
        lead.update_columns(spam: true)

        get admin_lead_path(lead)
        expect(response.body).not_to include("also permanently delete customer")
      end
    end
  end
end
