require "rails_helper"

RSpec.describe "Admin::Invoices", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:project) { create(:project) }

  before { sign_in admin }

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
end
