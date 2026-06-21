require "rails_helper"

RSpec.describe "Admin::OrderForms", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:project) { create(:project) }

  before { sign_in admin }

  describe "GET /admin/projects/:project_id/order_forms/new" do
    it "renders new form" do
      get new_admin_project_order_form_path(project)
      expect(response).to be_successful
    end
  end

  describe "POST /admin/projects/:project_id/order_forms" do
    it "creates an order form with line items" do
      expect {
        post admin_project_order_forms_path(project), params: {
          order_form: {
            supplier_name: "Cabinet Supply Co",
            line_items_attributes: {
              "0" => { name: "Shaker Door", quantity: 10, supplier_cost: 45.0, our_price: 65.0 }
            }
          }
        }
      }.to change(OrderForm, :count).by(1)

      of = OrderForm.last
      expect(of.supplier_name).to eq("Cabinet Supply Co")
      expect(of.line_items.count).to eq(1)
      expect(of.line_items.first.name).to eq("Shaker Door")
    end
  end

  describe "PATCH /admin/projects/:project_id/order_forms/:id/submit_order" do
    let(:order_form) { create(:order_form, project: project) }

    it "marks as submitted" do
      patch submit_order_admin_project_order_form_path(project, order_form)
      expect(order_form.reload).to be_submitted
    end
  end

  describe "DELETE /admin/projects/:project_id/order_forms/:id" do
    let!(:order_form) { create(:order_form, project: project) }

    it "deletes the order form" do
      expect {
        delete admin_project_order_form_path(project, order_form)
      }.to change(OrderForm, :count).by(-1)
    end
  end
end
