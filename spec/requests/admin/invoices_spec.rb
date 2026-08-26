require "rails_helper"

RSpec.describe "Admin::Invoices", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:project) { create(:project) }

  before { sign_in admin }

  describe "GET /admin/invoices" do
    it "renders the index" do
      create(:invoice, project: project)
      get admin_invoices_path
      expect(response).to be_successful
    end

    it "filters by status" do
      create(:invoice, project: project, status: :sent)
      get admin_invoices_path(status: "sent")
      expect(response).to be_successful
    end
  end

  describe "GET /admin/invoices/new" do
    it "renders new form without a project" do
      get new_admin_invoice_path
      expect(response).to be_successful
    end
  end

  describe "POST /admin/invoices" do
    it "creates a standalone invoice" do
      expect {
        post admin_invoices_path, params: {
          invoice: {
            issued_date: Date.current,
            due_date: Date.current + 30,
            line_items_attributes: {
              "0" => { name: "Consulting", quantity: 1, unit_price: 500 }
            }
          }
        }
      }.to change(Invoice, :count).by(1)

      inv = Invoice.last
      expect(inv.project).to be_nil
      expect(inv.line_items.first.name).to eq("Consulting")
    end
  end

  describe "GET /admin/projects/:project_id/invoices/new" do
    it "renders new form" do
      get new_admin_project_invoice_path(project)
      expect(response).to be_successful
    end
  end

  describe "POST /admin/projects/:project_id/invoices" do
    it "creates an invoice with line items" do
      expect {
        post admin_project_invoices_path(project), params: {
          invoice: {
            issued_date: Date.current,
            due_date: Date.current + 30,
            deposit_amount: 2000,
            line_items_attributes: {
              "0" => { name: "Materials", quantity: 1, unit_price: 3500 },
              "1" => { name: "Labor", quantity: 1, unit_price: 3500 }
            }
          }
        }
      }.to change(Invoice, :count).by(1)

      inv = Invoice.last
      expect(inv.line_items.count).to eq(2)
      expect(inv.total).to eq(7000.0)
    end
  end

  describe "PATCH /admin/projects/:project_id/invoices/:id/send_invoice" do
    let(:invoice) { create(:invoice, project: project) }

    it "marks as sent" do
      patch send_invoice_admin_project_invoice_path(project, invoice)
      expect(invoice.reload).to be_sent
    end
  end

  describe "PATCH /admin/projects/:project_id/invoices/:id/record_payment" do
    let(:invoice) { create(:invoice, :with_items, project: project) }

    it "records a deposit payment" do
      patch record_payment_admin_project_invoice_path(project, invoice), params: {
        amount: 2000, payment_type: "deposit"
      }
      expect(invoice.reload.amount_paid).to eq(2000.0)
      expect(invoice.deposit_paid?).to be true
    end
  end

  describe "DELETE /admin/projects/:project_id/invoices/:id" do
    let!(:invoice) { create(:invoice, project: project) }

    it "deletes the invoice" do
      expect {
        delete admin_project_invoice_path(project, invoice)
      }.to change(Invoice, :count).by(-1)
    end
  end

  describe "GET /admin/invoices/:id/pdf" do
    let(:invoice) { create(:invoice, :with_items, project: project) }

    it "returns a PDF" do
      get pdf_admin_invoice_path(invoice)
      expect(response).to be_successful
      expect(response.content_type).to include("application/pdf")
    end

    it "renders inline by default" do
      get pdf_admin_invoice_path(invoice)
      expect(response.headers["Content-Disposition"]).to include("inline")
    end

    it "downloads when requested" do
      get pdf_admin_invoice_path(invoice, download: true)
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.headers["Content-Disposition"]).to include(invoice.invoice_number)
    end
  end

  describe "GET /admin/projects/:project_id/invoices/:id/pdf" do
    let(:invoice) { create(:invoice, :with_items, project: project) }

    it "returns a PDF via the nested route" do
      get pdf_admin_project_invoice_path(project, invoice)
      expect(response).to be_successful
      expect(response.content_type).to include("application/pdf")
    end
  end
end
