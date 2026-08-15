require "rails_helper"

RSpec.describe "Address map on admin pages", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:lead) { create(:lead, address_street: "100 S Washington St", address_city: "Oxford", address_state: "MI", address_zip: "48371") }
  let(:project) { create(:project, address: "100 S Washington St, Oxford MI 48371") }

  before { sign_in admin }

  describe "admin pages use precise coordinates" do
    it "includes admin_geo lat/lng on project show page" do
      get admin_project_path(project)
      expect(response.body).to include('data-address-map-business-lat-value="42.8340"')
      expect(response.body).to include('data-address-map-business-lng-value="-83.3428"')
    end

    it "includes admin_geo lat/lng on lead show page" do
      get admin_lead_path(lead)
      expect(response.body).to include('data-address-map-business-lat-value="42.8340"')
      expect(response.body).to include('data-address-map-business-lng-value="-83.3428"')
    end

    it "includes admin_geo lat/lng on lead edit page" do
      get edit_admin_lead_path(lead)
      expect(response.body).to include('data-address-map-business-lat-value="42.8340"')
      expect(response.body).to include('data-address-map-business-lng-value="-83.3428"')
    end

    it "includes admin_geo lat/lng on project edit page" do
      get edit_admin_project_path(project)
      expect(response.body).to include('data-address-map-business-lat-value="42.8340"')
      expect(response.body).to include('data-address-map-business-lng-value="-83.3428"')
    end
  end

  describe "error target" do
    it "is present on project show page" do
      get admin_project_path(project)
      expect(response.body).to include('data-address-map-target="error"')
    end

    it "is present on lead show page" do
      get admin_lead_path(lead)
      expect(response.body).to include('data-address-map-target="error"')
    end

    it "is present on lead edit page" do
      get edit_admin_lead_path(lead)
      expect(response.body).to include('data-address-map-target="error"')
    end

    it "is present on project edit page" do
      get edit_admin_project_path(project)
      expect(response.body).to include('data-address-map-target="error"')
    end
  end

  describe "address data on show pages" do
    it "passes project address as fullAddress target" do
      get admin_project_path(project)
      expect(response.body).to include('data-address-map-target="fullAddress"')
      expect(response.body).to include(project.address)
    end

    it "passes lead address fields as individual targets" do
      get admin_lead_path(lead)
      expect(response.body).to include('data-address-map-target="street"')
      expect(response.body).to include('data-address-map-target="city"')
      expect(response.body).to include('data-address-map-target="state"')
      expect(response.body).to include('data-address-map-target="zip"')
    end
  end

  describe "precise coordinates not exposed on public pages" do
    before { sign_out admin }

    %w[/ /about /gallery /contact].each do |path|
      it "does not expose precise business coordinates on #{path}" do
        get path
        expect(response.body).not_to include('data-controller="address-map"')
        expect(response.body).not_to include("42.8340")
        expect(response.body).not_to include("-83.3428")
      end
    end
  end
end
