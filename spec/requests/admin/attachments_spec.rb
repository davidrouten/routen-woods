require "rails_helper"

RSpec.describe "Admin::Attachments", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:project) { create(:project) }

  before { sign_in admin }

  # --- Project attachments ---

  describe "GET /admin/projects/:project_id/attachments/:id" do
    let(:attachment) { create(:attachment, attachable: project, uploaded_by: admin, description: "Check scan") }

    it "renders the show page" do
      get admin_project_attachment_path(project, attachment)
      expect(response).to be_successful
    end

    it "displays file metadata" do
      get admin_project_attachment_path(project, attachment)
      expect(response.body).to include("test-document.pdf")
      expect(response.body).to include(admin.full_name)
      expect(response.body).to include("Check scan")
    end

    it "links back to the project" do
      get admin_project_attachment_path(project, attachment)
      expect(response.body).to include(admin_project_path(project))
    end
  end

  describe "GET /admin/projects/:project_id/attachments/:id/edit" do
    let(:attachment) { create(:attachment, attachable: project) }

    it "renders the edit form" do
      get edit_admin_project_attachment_path(project, attachment)
      expect(response).to be_successful
    end
  end

  describe "PATCH /admin/projects/:project_id/attachments/:id" do
    let(:attachment) { create(:attachment, attachable: project) }

    it "updates the description" do
      patch admin_project_attachment_path(project, attachment), params: {
        attachment: { description: "Updated description" }
      }
      expect(attachment.reload.description).to eq("Updated description")
      expect(response).to redirect_to(admin_project_attachment_path(project, attachment))
    end

    it "moves the attachment to a different project" do
      other_project = create(:project, title: "Other Project")
      patch admin_project_attachment_path(project, attachment), params: {
        attachment: { attachable_gid: "Project-#{other_project.id}" }
      }
      expect(attachment.reload.attachable).to eq(other_project)
      expect(response).to redirect_to(admin_project_attachment_path(other_project, attachment))
    end

    it "moves the attachment to an invoice" do
      invoice = create(:invoice, project: project)
      patch admin_project_attachment_path(project, attachment), params: {
        attachment: { attachable_gid: "Invoice-#{invoice.id}" }
      }
      expect(attachment.reload.attachable).to eq(invoice)
      expect(response).to redirect_to(admin_invoice_attachment_path(invoice, attachment))
    end

    it "moves the attachment to an order form" do
      order_form = create(:order_form, project: project)
      patch admin_project_attachment_path(project, attachment), params: {
        attachment: { attachable_gid: "OrderForm-#{order_form.id}" }
      }
      expect(attachment.reload.attachable).to eq(order_form)
      expect(response).to redirect_to(admin_order_form_attachment_path(order_form, attachment))
    end

    it "clears the description" do
      attachment.update!(description: "Old note")
      patch admin_project_attachment_path(project, attachment), params: {
        attachment: { description: "" }
      }
      expect(attachment.reload.description).to eq("")
    end
  end

  describe "POST /admin/projects/:project_id/attachments" do
    it "uploads a single file" do
      pdf = Rack::Test::UploadedFile.new(StringIO.new("test content"), "application/pdf", false, original_filename: "contract.pdf")
      expect {
        post admin_project_attachments_path(project), params: { files: [pdf] }
      }.to change(Attachment, :count).by(1)

      attachment = Attachment.last
      expect(attachment.attachable).to eq(project)
      expect(attachment.uploaded_by).to eq(admin)
      expect(attachment.file).to be_attached
      expect(response).to redirect_to(admin_project_path(project))
    end

    it "uploads multiple files" do
      pdf1 = Rack::Test::UploadedFile.new(StringIO.new("content 1"), "application/pdf", false, original_filename: "doc1.pdf")
      pdf2 = Rack::Test::UploadedFile.new(StringIO.new("content 2"), "application/pdf", false, original_filename: "doc2.pdf")
      expect {
        post admin_project_attachments_path(project), params: { files: [pdf1, pdf2] }
      }.to change(Attachment, :count).by(2)
    end

    it "redirects with alert when no files provided" do
      post admin_project_attachments_path(project), params: {}
      expect(response).to redirect_to(admin_project_path(project))
      expect(flash[:alert]).to eq("No files selected.")
    end

    it "saves description when provided" do
      pdf = Rack::Test::UploadedFile.new(StringIO.new("test"), "application/pdf", false, original_filename: "contract.pdf")
      post admin_project_attachments_path(project), params: { files: [pdf], description: "Signed contract" }
      expect(Attachment.last.description).to eq("Signed contract")
    end
  end

  describe "DELETE /admin/projects/:project_id/attachments/:id" do
    let!(:attachment) { create(:attachment, attachable: project) }

    it "deletes the attachment" do
      expect {
        delete admin_project_attachment_path(project, attachment)
      }.to change(Attachment, :count).by(-1)
      expect(response).to redirect_to(admin_project_path(project))
    end
  end

  describe "GET /admin/projects/:project_id (attachments section)" do
    it "shows attachments on the project page" do
      create(:attachment, attachable: project, uploaded_by: admin)
      get admin_project_path(project)
      expect(response).to be_successful
      expect(response.body).to include("Attachments")
      expect(response.body).to include("test-document.pdf")
    end

    it "shows empty state when no attachments" do
      get admin_project_path(project)
      expect(response).to be_successful
      expect(response.body).to include("Attachments")
    end
  end

  # --- Invoice attachments ---

  describe "invoice attachments" do
    let(:invoice) { create(:invoice, project: project) }

    it "uploads a file to an invoice" do
      pdf = Rack::Test::UploadedFile.new(StringIO.new("check scan"), "image/jpeg", false, original_filename: "check.jpg")
      expect {
        post admin_invoice_attachments_path(invoice), params: { files: [pdf] }
      }.to change(Attachment, :count).by(1)

      expect(Attachment.last.attachable).to eq(invoice)
      expect(response).to redirect_to(admin_invoice_path(invoice))
    end

    it "shows the attachment" do
      attachment = create(:attachment, :on_invoice, attachable: invoice, uploaded_by: admin)
      get admin_invoice_attachment_path(invoice, attachment)
      expect(response).to be_successful
      expect(response.body).to include("test-document.pdf")
    end

    it "renders the edit form" do
      attachment = create(:attachment, :on_invoice, attachable: invoice)
      get edit_admin_invoice_attachment_path(invoice, attachment)
      expect(response).to be_successful
    end

    it "updates the description" do
      attachment = create(:attachment, :on_invoice, attachable: invoice)
      patch admin_invoice_attachment_path(invoice, attachment), params: {
        attachment: { description: "Check scan front" }
      }
      expect(attachment.reload.description).to eq("Check scan front")
      expect(response).to redirect_to(admin_invoice_attachment_path(invoice, attachment))
    end

    it "moves the attachment to a project" do
      attachment = create(:attachment, :on_invoice, attachable: invoice)
      patch admin_invoice_attachment_path(invoice, attachment), params: {
        attachment: { attachable_gid: "Project-#{project.id}" }
      }
      expect(attachment.reload.attachable).to eq(project)
      expect(response).to redirect_to(admin_project_attachment_path(project, attachment))
    end

    it "deletes an invoice attachment" do
      attachment = create(:attachment, :on_invoice, attachable: invoice)
      expect {
        delete admin_invoice_attachment_path(invoice, attachment)
      }.to change(Attachment, :count).by(-1)
    end

    it "shows attachments on the invoice show page" do
      create(:attachment, :on_invoice, attachable: invoice, uploaded_by: admin)
      get admin_invoice_path(invoice)
      expect(response).to be_successful
      expect(response.body).to include("Attachments")
      expect(response.body).to include("test-document.pdf")
    end
  end

  # --- Order form attachments ---

  describe "order form attachments" do
    let(:order_form) { create(:order_form, project: project) }

    it "uploads a file to an order form" do
      pdf = Rack::Test::UploadedFile.new(StringIO.new("receipt"), "application/pdf", false, original_filename: "receipt.pdf")
      expect {
        post admin_order_form_attachments_path(order_form), params: { files: [pdf] }
      }.to change(Attachment, :count).by(1)

      expect(Attachment.last.attachable).to eq(order_form)
      expect(response).to redirect_to(admin_order_form_path(order_form))
    end

    it "shows the attachment" do
      attachment = create(:attachment, :on_order_form, attachable: order_form, uploaded_by: admin)
      get admin_order_form_attachment_path(order_form, attachment)
      expect(response).to be_successful
      expect(response.body).to include("test-document.pdf")
    end

    it "renders the edit form" do
      attachment = create(:attachment, :on_order_form, attachable: order_form)
      get edit_admin_order_form_attachment_path(order_form, attachment)
      expect(response).to be_successful
    end

    it "updates the description" do
      attachment = create(:attachment, :on_order_form, attachable: order_form)
      patch admin_order_form_attachment_path(order_form, attachment), params: {
        attachment: { description: "Supplier receipt" }
      }
      expect(attachment.reload.description).to eq("Supplier receipt")
      expect(response).to redirect_to(admin_order_form_attachment_path(order_form, attachment))
    end

    it "moves the attachment to an invoice" do
      invoice = create(:invoice, project: project)
      attachment = create(:attachment, :on_order_form, attachable: order_form)
      patch admin_order_form_attachment_path(order_form, attachment), params: {
        attachment: { attachable_gid: "Invoice-#{invoice.id}" }
      }
      expect(attachment.reload.attachable).to eq(invoice)
      expect(response).to redirect_to(admin_invoice_attachment_path(invoice, attachment))
    end

    it "deletes an order form attachment" do
      attachment = create(:attachment, :on_order_form, attachable: order_form)
      expect {
        delete admin_order_form_attachment_path(order_form, attachment)
      }.to change(Attachment, :count).by(-1)
    end

    it "shows attachments on the order form show page" do
      create(:attachment, :on_order_form, attachable: order_form, uploaded_by: admin)
      get admin_order_form_path(order_form)
      expect(response).to be_successful
      expect(response.body).to include("Attachments")
      expect(response.body).to include("test-document.pdf")
    end
  end

  # --- Invalid attachable_gid ---

  describe "invalid attachable_gid" do
    let(:attachment) { create(:attachment, attachable: project) }

    it "ignores a disallowed type and keeps the current attachable" do
      patch admin_project_attachment_path(project, attachment), params: {
        attachment: { attachable_gid: "User-#{admin.id}" }
      }
      expect(attachment.reload.attachable).to eq(project)
      expect(response).to redirect_to(admin_project_attachment_path(project, attachment))
    end

    it "ignores a completely bogus gid format" do
      patch admin_project_attachment_path(project, attachment), params: {
        attachment: { attachable_gid: "nonsense" }
      }
      expect(attachment.reload.attachable).to eq(project)
      expect(response).to redirect_to(admin_project_attachment_path(project, attachment))
    end
  end
end
