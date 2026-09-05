require "rails_helper"

RSpec.describe "Admin::Projects", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:lead) { create(:lead) }

  before { sign_in admin }

  describe "GET /admin/projects" do
    it "lists projects" do
      create(:project, title: "Kitchen Refacing")
      get admin_projects_path
      expect(response).to be_successful
      expect(response.body).to include("Kitchen Refacing")
    end

    it "sorts by project title ascending" do
      create(:project, title: "Zephyr Kitchen")
      create(:project, title: "Alpha Closet")
      get admin_projects_path, params: { sort: "project" }
      expect(response).to be_successful
      expect(response.body.index("Alpha Closet")).to be < response.body.index("Zephyr Kitchen")
    end

    it "sorts by project title descending" do
      create(:project, title: "Zephyr Kitchen")
      create(:project, title: "Alpha Closet")
      get admin_projects_path, params: { sort: "-project" }
      expect(response).to be_successful
      expect(response.body.index("Zephyr Kitchen")).to be < response.body.index("Alpha Closet")
    end

    it "sorts by client name" do
      lead_a = create(:lead, first_name: "Zara", email: "z@example.com")
      lead_b = create(:lead, first_name: "Alice", email: "a@example.com")
      create(:project, title: "P1", lead: lead_a)
      create(:project, title: "P2", lead: lead_b)
      get admin_projects_path, params: { sort: "client" }
      expect(response).to be_successful
    end

    it "sorts by price descending" do
      create(:project, title: "Cheap", agreed_price: 1000)
      create(:project, title: "Expensive", agreed_price: 9000)
      get admin_projects_path, params: { sort: "-price" }
      expect(response).to be_successful
      expect(response.body.index("Expensive")).to be < response.body.index("Cheap")
    end

    it "sorts by schedule ascending" do
      create(:project, title: "Later", scheduled_start_date: 30.days.from_now.to_date)
      create(:project, title: "Soon", scheduled_start_date: 2.days.from_now.to_date)
      get admin_projects_path, params: { sort: "schedule" }
      expect(response).to be_successful
      expect(response.body.index("Soon")).to be < response.body.index("Later")
    end
  end

  describe "GET /admin/projects/new" do
    it "renders new form" do
      get new_admin_project_path
      expect(response).to be_successful
    end

    it "prefills from lead when lead_id provided" do
      get new_admin_project_path(lead_id: lead.id)
      expect(response).to be_successful
      expect(response.body).to include(lead.email)
    end
  end

  describe "POST /admin/projects" do
    it "creates a project" do
      expect {
        post admin_projects_path, params: {
          project: { lead_id: lead.id, title: "New Kitchen Job", email: "client@example.com" }
        }
      }.to change(Project, :count).by(1)

      expect(response).to redirect_to(admin_project_path(Project.last))
    end

    it "transitions lead to booked" do
      post admin_projects_path, params: {
        project: { lead_id: lead.id, title: "New Job" }
      }
      expect(lead.reload).to be_booked
    end

    it "inherits customer_id from the lead" do
      customer = create(:customer)
      lead.update_column(:customer_id, customer.id)

      post admin_projects_path, params: {
        project: { lead_id: lead.id, title: "Customer Inherited Job" }
      }

      expect(Project.last.customer_id).to eq(customer.id)
    end
  end

  describe "PATCH /admin/projects/:id" do
    let(:project) { create(:project) }

    it "updates project details" do
      patch admin_project_path(project), params: {
        project: { agreed_price: 8500.00 }
      }
      expect(project.reload.agreed_price).to eq(8500.0)
    end

    it "updates the calendar color" do
      patch admin_project_path(project), params: {
        project: { calendar_color: "#EC4899" }
      }
      expect(project.reload.calendar_color).to eq("#EC4899")
    end
  end

  describe "PATCH /admin/projects/:id/transition" do
    let(:project) { create(:project) }

    it "transitions to in_progress" do
      patch transition_admin_project_path(project), params: { status: "in_progress" }
      expect(project.reload).to be_in_progress
      expect(project.started_at).to be_present
    end
  end

  describe "DELETE /admin/projects/:id" do
    let!(:project) { create(:project) }

    it "deletes the project" do
      expect { delete admin_project_path(project) }.to change(Project, :count).by(-1)
    end
  end
end
