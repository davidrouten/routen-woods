require "rails_helper"

RSpec.describe "Admin::Customers", type: :request do
  let(:admin) { create(:user, :admin) }

  before { sign_in admin }

  describe "GET /admin/customers" do
    it "renders the customers index" do
      create(:customer)
      get admin_customers_path
      expect(response).to have_http_status(:ok)
    end

    it "filters by search query" do
      create(:customer, first_name: "Alice", last_name: "Johnson")
      create(:customer, first_name: "Bob", last_name: "Smith")

      get admin_customers_path, params: { q: "Alice" }
      expect(response.body).to include("Alice")
      expect(response.body).not_to include("Bob")
    end

    context "when not authenticated" do
      before { sign_out admin }

      it "redirects to login" do
        get admin_customers_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/customers/:id" do
    it "renders the customer show page" do
      customer = create(:customer)
      lead = create(:lead, customer: customer)
      project = create(:project, customer: customer, lead: lead)

      get admin_customer_path(customer)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(customer.full_name)
    end
  end

  describe "GET /admin/customers/:id/edit" do
    it "renders the edit form" do
      customer = create(:customer)
      get edit_admin_customer_path(customer)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/customers/:id" do
    let(:customer) { create(:customer, first_name: "Jane") }

    it "updates the customer" do
      patch admin_customer_path(customer), params: { customer: { first_name: "Janet" } }
      expect(response).to redirect_to(admin_customer_path(customer))
      expect(customer.reload.first_name).to eq("Janet")
    end

    it "re-renders edit on validation error" do
      patch admin_customer_path(customer), params: { customer: { first_name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /admin/customers/suggest" do
    before do
      allow_any_instance_of(Lead).to receive(:link_to_customer)
    end

    it "returns matching customers as JSON" do
      customer = create(:customer, email: "match@example.com")
      create(:lead, customer: customer)

      get suggest_admin_customers_path, params: { email: "match@example.com" }, headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json[0]["id"]).to eq(customer.id)
      expect(json[0]["name"]).to eq(customer.full_name)
    end

    it "returns empty array when no matches" do
      get suggest_admin_customers_path, params: { email: "nobody@example.com" }, headers: { "Accept" => "application/json" }
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end
  end
end
