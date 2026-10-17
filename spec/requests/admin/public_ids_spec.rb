require "rails_helper"

RSpec.describe "Admin public IDs", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "old numeric links" do
    let(:lead) { create(:lead) }

    it "redirect signed-in users to the public-ID URL" do
      sign_in admin

      get "/admin/leads/#{lead.id}"

      expect(response).to redirect_to("/admin/leads/#{lead.public_id}")
    end

    it "rewrite every id in nested paths and keep the query string" do
      sign_in admin
      project = create(:project)
      invoice = create(:invoice, project: project)

      get "/admin/projects/#{project.id}/invoices/#{invoice.id}/edit?tab=items"

      expect(response).to redirect_to("/admin/projects/#{project.public_id}/invoices/#{invoice.public_id}/edit?tab=items")
    end

    it "404s when the numeric id doesn't exist" do
      sign_in admin

      get "/admin/leads/999999"

      expect(response).to have_http_status(:not_found)
    end

    it "send guests to sign in without revealing the record" do
      get "/admin/leads/#{lead.id}"

      expect(response).to redirect_to("/users/sign_in")
    end

    it "only apply to GET requests" do
      sign_in admin

      patch "/admin/leads/#{lead.id}", params: { lead: { first_name: "X" } }

      expect(response).to have_http_status(:not_found)
      expect(lead.reload.first_name).not_to eq("X")
    end
  end

  describe "forms send public IDs for related records" do
    before { sign_in admin }

    it "links a lead to a customer by public ID" do
      customer = create(:customer)
      lead = create(:lead)

      patch admin_lead_path(lead), params: { lead: { customer_id: customer.public_id } }

      expect(lead.reload.customer).to eq(customer)
    end

    it "clears the customer when the field is blank" do
      lead = create(:lead, customer: create(:customer))

      patch admin_lead_path(lead), params: { lead: { customer_id: "" } }

      expect(lead.reload.customer).to be_nil
    end

    it "rejects an internal id" do
      lead = create(:lead)
      other = create(:customer, email: "other@example.com", phone: "813-555-0199")

      patch admin_lead_path(lead), params: { lead: { customer_id: other.id } }

      expect(response).to have_http_status(:not_found)
      expect(lead.reload.customer).not_to eq(other)
    end

    it "assigns an invoice to a project by public ID" do
      project = create(:project)
      invoice = create(:invoice, project: nil)

      patch admin_invoice_path(invoice), params: { invoice: { project_id: project.public_id } }

      expect(invoice.reload.project).to eq(project)
    end

    it "lists only active projects in the invoice project dropdown, by public ID" do
      active = create(:project, title: "Active Job")
      archived = create(:project, title: "Archived Job")
      archived.discard

      get new_admin_invoice_path

      expect(response.body).to include(%(value="#{active.public_id}"))
      expect(response.body).not_to include("Archived Job")
    end
  end

  describe "pages don't expose internal ids" do
    before { sign_in admin }

    it "lead pages link with public IDs only" do
      lead = create(:lead)

      get admin_lead_path(lead)

      expect(response.body).to include(lead.public_id)
      expect(response.body).not_to include("/admin/leads/#{lead.id}\"")
      expect(response.body).not_to include("lead_id=#{lead.id}\"")
    end
  end
end
