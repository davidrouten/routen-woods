require "rails_helper"

RSpec.describe "Admin::Schedule", type: :request do
  let(:admin) { create(:user, :admin) }

  before { sign_in admin }

  describe "GET /admin/schedule" do
    it "renders successfully" do
      get admin_schedule_path
      expect(response).to be_successful
    end

    it "includes scheduled projects in JSON data attribute" do
      project = create(:project, title: "Kitchen Refacing",
                       scheduled_start_date: Date.current,
                       estimated_duration_days: 3)

      get admin_schedule_path
      expect(response.body).to include("Kitchen Refacing")
    end

    it "lists unscheduled projects in the sidebar" do
      create(:project, title: "No Date Yet", scheduled_start_date: nil, estimated_duration_days: nil)

      get admin_schedule_path
      expect(response.body).to include("No Date Yet")
      expect(response.body).to include("Unscheduled Projects")
    end

    it "excludes completed projects from scheduled list by default" do
      create(:project, :complete, title: "Done Project",
             scheduled_start_date: 1.week.ago.to_date,
             estimated_duration_days: 3)

      get admin_schedule_path
      body = response.body
      json_match = body.match(/data-schedule-calendar-projects-value="([^"]*)"/)
      projects_json = CGI.unescapeHTML(json_match[1])
      projects = JSON.parse(projects_json)
      expect(projects.map { |p| p["title"] }).not_to include("Done Project")
    end

    it "includes project with customer name" do
      customer = create(:customer, first_name: "Jane", last_name: "Smith")
      create(:project, title: "Cabinet Install", customer: customer,
             scheduled_start_date: Date.current, estimated_duration_days: 2)

      get admin_schedule_path
      expect(response.body).to include("Jane S.")
    end

    it "requires authentication" do
      sign_out admin
      get admin_schedule_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
