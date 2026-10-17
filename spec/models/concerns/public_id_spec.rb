require "rails_helper"

RSpec.describe PublicId do
  UUID_FORMAT = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/

  describe "models with a public_id" do
    let(:lead) { create(:lead) }

    it "gets a UUID from Postgres on create, without a reload" do
      expect(Lead.create!(attributes_for(:lead)).public_id).to match(UUID_FORMAT)
    end

    it "gives each record a different public_id" do
      expect(create(:lead).public_id).not_to eq(lead.public_id)
    end

    it "uses the public_id in URLs" do
      expect(lead.to_param).to eq(lead.public_id)
      expect(Rails.application.routes.url_helpers.admin_lead_path(lead)).to eq("/admin/leads/#{lead.public_id}")
    end

    it "uses the public_id in HTML element ids" do
      expect(ActionView::RecordIdentifier.dom_id(lead)).to eq("lead_#{lead.public_id}")
    end

    it "has no to_param before it is saved" do
      expect(Lead.new.to_param).to be_nil
    end
  end

  describe ".find_public!" do
    let!(:lead) { create(:lead) }

    it "finds by public_id" do
      expect(Lead.find_public!(lead.public_id)).to eq(lead)
    end

    it "works on scopes" do
      expect(Lead.kept.find_public!(lead.public_id)).to eq(lead)
    end

    it "raises RecordNotFound for an internal id" do
      expect { Lead.find_public!(lead.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "raises RecordNotFound for garbage" do
      expect { Lead.find_public!("not-a-uuid") }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "models without a public_id column" do
    it "keep using the internal id" do
      user = create(:user)

      expect(user.to_param).to eq(user.id.to_s)
      expect(ActionView::RecordIdentifier.dom_id(user)).to eq("user_#{user.id}")
    end
  end
end
