require "rails_helper"

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "renders the home page" do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /about" do
    it "renders the about page" do
      get about_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /services" do
    it "renders the services page" do
      get services_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /gallery" do
    it "renders the gallery page" do
      get gallery_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /contact" do
    it "renders the contact page" do
      get contact_path
      expect(response).to have_http_status(:ok)
    end
  end
end
