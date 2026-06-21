require "rails_helper"

RSpec.describe "Leads", type: :request do
  describe "POST /leads" do
    let(:valid_params) do
      {
        lead: {
          first_name: "Jane",
          email: "jane@example.com",
          phone: "813-555-0100",
          services_interested_in: ["cabinet_refacing"],
          message: "I need my cabinets refaced"
        }
      }
    end

    it "creates a new lead" do
      expect { post leads_path, params: valid_params }
        .to change(Lead, :count).by(1)
    end

    it "redirects to root with success notice" do
      post leads_path, params: valid_params
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq(I18n.t("business.forms.contact.success"))
    end

    context "with invalid params" do
      it "does not create a lead with missing required fields" do
        expect { post leads_path, params: { lead: { first_name: "" } } }
          .not_to change(Lead, :count)
      end
    end

    context "with spam indicators" do
      it "creates the lead but marks it as spam" do
        post leads_path, params: {
          lead: valid_params[:lead].merge(honeypot_value: "gotcha")
        }
        expect(Lead.last.spam).to be true
      end
    end
  end
end
