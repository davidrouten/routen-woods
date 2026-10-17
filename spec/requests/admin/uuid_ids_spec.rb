require "rails_helper"

RSpec.describe "Admin with UUID ids", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "old integer links (pre-UUID notification emails)" do
    it "redirect signed-in admins to the UUID URL" do
      sign_in admin
      lead = create(:lead, legacy_id: 42)

      get "/admin/leads/42"

      expect(response).to redirect_to("/admin/leads/#{lead.id}")
    end

    it "rewrite every id in nested paths and keep the query string" do
      sign_in admin
      project = create(:project, legacy_id: 12)
      invoice = create(:invoice, project: project, legacy_id: 5)

      get "/admin/projects/12/invoices/5/edit?tab=items"

      expect(response).to redirect_to("/admin/projects/#{project.id}/invoices/#{invoice.id}/edit?tab=items")
    end

    it "404 when no record has that legacy id" do
      sign_in admin

      get "/admin/leads/999999"

      expect(response).to have_http_status(:not_found)
    end

    it "send guests to sign in first" do
      create(:lead, legacy_id: 42)

      get "/admin/leads/42"

      expect(response).to redirect_to("/users/sign_in")
    end

    it "only apply to GET requests" do
      sign_in admin
      lead = create(:lead, legacy_id: 42)

      patch "/admin/leads/42", params: { lead: { first_name: "X" } }

      expect(response).to have_http_status(:not_found)
      expect(lead.reload.first_name).not_to eq("X")
    end
  end

  describe "nested invoice forms" do
    before { sign_in admin }

    it "render UUIDs for child rows and save edits, deletes and additions" do
      invoice = create(:invoice)
      keep = create(:invoice_line_item, invoice: invoice, name: "Keep")
      drop = create(:invoice_line_item, invoice: invoice, name: "Drop")

      get edit_admin_invoice_path(invoice)
      hidden_ids = response.body.scan(/name="invoice\[line_items_attributes\]\[\d+\]\[id\]"[^>]*value="([^"]+)"/).flatten +
                   response.body.scan(/value="([^"]+)"[^>]*name="invoice\[line_items_attributes\]\[\d+\]\[id\]"/).flatten
      expect(hidden_ids).to contain_exactly(keep.id, drop.id)

      patch admin_invoice_path(invoice), params: { invoice: { line_items_attributes: {
        "0" => { id: keep.id, name: "Kept and renamed" },
        "1" => { id: drop.id, _destroy: "1" },
        "2" => { name: "Added", quantity: 1, unit_price: 10 }
      } } }

      expect(invoice.line_items.reload.map(&:name)).to contain_exactly("Kept and renamed", "Added")
    end

    it "reject another invoice's line item" do
      invoice = create(:invoice)
      other = create(:invoice_line_item, invoice: create(:invoice), name: "Not yours")

      patch admin_invoice_path(invoice), params: { invoice: { line_items_attributes: {
        "0" => { id: other.id, name: "Hijacked" }
      } } }

      expect(response).to have_http_status(:not_found)
      expect(other.reload.name).to eq("Not yours")
    end
  end

  describe "project dropdowns" do
    before { sign_in admin }

    it "list only active projects" do
      active = create(:project, title: "Active Job")
      create(:project, title: "Archived Job").discard

      get new_admin_invoice_path

      expect(response.body).to include(%(value="#{active.id}"))
      expect(response.body).not_to include("Archived Job")
    end
  end

  describe "pages" do
    before { sign_in admin }

    it "contain no integer record ids" do
      lead = create(:lead, legacy_id: 4512)

      get admin_lead_path(lead)

      expect(response.body).to include(lead.id)
      expect(response.body).not_to include("4512")
    end

    it "render the dashboard and schedule with UUID project ids" do
      project = create(:project, scheduled_start_date: Date.current)

      get admin_root_path
      expect(response).to have_http_status(:ok)

      get admin_schedule_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(project.id)
    end
  end
end
