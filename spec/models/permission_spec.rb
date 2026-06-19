require "rails_helper"

RSpec.describe Permission, type: :model do
  describe "validations" do
    subject { build(:permission) }

    it { is_expected.to validate_presence_of(:resource) }
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_inclusion_of(:resource).in_array(Permission::RESOURCES) }
    it { is_expected.to validate_inclusion_of(:action).in_array(Permission::ACTIONS) }
    it { is_expected.to validate_uniqueness_of(:action).scoped_to(:resource) }
  end

  describe "associations" do
    it { is_expected.to have_many(:user_permissions).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_permissions) }
  end

  describe "#to_s" do
    it "formats as action:resource" do
      perm = build(:permission, resource: "leads", action: "view")
      expect(perm.to_s).to eq("view:leads")
    end
  end
end
