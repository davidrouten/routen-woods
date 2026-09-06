require "rails_helper"

RSpec.describe "Admin::Attachments", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:project) { create(:project) }

  before { sign_in admin }

  describe "POST /admin/projects/:project_id/attachments" do
    let(:file) { fixture_file_upload(StringIO.new("test content"), "test.pdf", "application/pdf") }

    it "uploads a single file" do
      pdf = Rack::Test::UploadedFile.new(StringIO.new("test content"), "application/pdf", false, original_filename: "contract.pdf")
      expect {
        post admin_project_attachments_path(project), params: { files: [pdf] }
      }.to change(Attachment, :count).by(1)

      attachment = Attachment.last
      expect(attachment.project).to eq(project)
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
    let!(:attachment) { create(:attachment, project: project) }

    it "deletes the attachment" do
      expect {
        delete admin_project_attachment_path(project, attachment)
      }.to change(Attachment, :count).by(-1)
      expect(response).to redirect_to(admin_project_path(project))
    end
  end
end
