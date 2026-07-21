require "rails_helper"

RSpec.describe "Services", type: :request do
  describe "GET /services/cabinet-refacing" do
    it "renders the cabinet refacing page" do
      get services_cabinet_refacing_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Cabinet Refacing")
    end
  end

  describe "GET /services/cabinet-repainting" do
    it "renders the cabinet repainting page" do
      get services_cabinet_repainting_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Cabinet Repainting")
    end
  end

  describe "GET /services/cabinet-installation" do
    it "renders the cabinet installation page" do
      get services_cabinet_installation_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Cabinet Installation")
    end
  end

  describe "GET /services/cabinet-customization-and-repair" do
    it "renders the customization, repair & accessories page" do
      get services_cabinet_customize_repair_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Customization, Repair")
    end
  end

  describe "GET /services/custom-closets-and-pantries" do
    it "renders the custom closets & pantries page" do
      get services_custom_closets_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Custom Closets")
    end
  end

  describe "GET /services/countertops" do
    it "renders the countertops page" do
      get services_countertops_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Countertops")
    end
  end
end
