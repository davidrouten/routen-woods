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

    it "creates a payment record" do
      expect {
        patch record_payment_admin_project_invoice_path(project, invoice), params: {
          payment: { amount: 2000, paid_at: Date.current, deposit: true }
        }
      }.to change(Payment, :count).by(1)

      payment = invoice.payments.last
      expect(payment.amount).to eq(2000.0)
      expect(payment).to be_deposit
      expect(invoice.reload).to be_partially_paid
    end

    it "marks invoice as paid when fully paid" do
      patch record_payment_admin_project_invoice_path(project, invoice), params: {
        payment: { amount: 7000, paid_at: Date.current }
      }
      expect(invoice.reload).to be_paid
    end
  end

  describe "PATCH /admin/invoices/:id (update with payments)" do
    let(:invoice) { create(:invoice, :with_items) }

    it "updates status manually" do
      patch admin_invoice_path(invoice), params: {
        invoice: { status: "sent" }
      }
      expect(invoice.reload).to be_sent
    end

    it "adds payments via nested attributes" do
      expect {
        patch admin_invoice_path(invoice), params: {
          invoice: {
            payments_attributes: {
              "0" => { amount: 1500, paid_at: Date.current, deposit: true, notes: "Deposit check" }
            }
          }
        }
      }.to change(Payment, :count).by(1)

      expect(invoice.payments.last.notes).to eq("Deposit check")
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

  describe "GET /admin/invoices/:id (show with payments)" do
    let(:invoice) { create(:invoice, :with_items, project: project) }

    it "renders the show page with payments" do
      create(:payment, invoice: invoice, amount: 2000, deposit: true)
      get admin_invoice_path(invoice)
      expect(response).to be_successful
      expect(response.body).to include("Payments")
    end
  end

  describe "GET /admin/invoices/:id/edit" do
    let(:invoice) { create(:invoice, :with_items, project: project) }

    it "renders the edit page with status and payments sections" do
      create(:payment, invoice: invoice, amount: 2000)
      get edit_admin_invoice_path(invoice)
      expect(response).to be_successful
      expect(response.body).to include("Payments")
    end
  end
end
