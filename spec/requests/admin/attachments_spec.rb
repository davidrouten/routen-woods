require "rails_helper"

RSpec.describe "Admin::Attachments", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:project) { create(:project) }

  before { sign_in admin }

  describe "GET /admin/projects/:project_id/attachments/:id" do
    let(:attachment) { create(:attachment, project: project, uploaded_by: admin, description: "Check scan") }

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
    let(:attachment) { create(:attachment, project: project) }

    it "renders the edit form" do
      get edit_admin_project_attachment_path(project, attachment)
      expect(response).to be_successful
    end

    it "shows the project selector" do
      get edit_admin_project_attachment_path(project, attachment)
      expect(response.body).to include("Project")
      expect(response.body).to include(project.title)
    end
  end

  describe "PATCH /admin/projects/:project_id/attachments/:id" do
    let(:attachment) { create(:attachment, project: project) }

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
        attachment: { project_id: other_project.id }
      }
      expect(attachment.reload.project).to eq(other_project)
      expect(response).to redirect_to(admin_project_attachment_path(other_project, attachment))
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

  describe "GET /admin/projects/:project_id (attachments section)" do
    it "shows attachments on the project page" do
      create(:attachment, project: project, uploaded_by: admin)
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
end
