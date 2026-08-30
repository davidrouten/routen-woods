require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
  end

  describe "associations" do
    it { is_expected.to have_many(:user_permissions).dependent(:destroy) }
    it { is_expected.to have_many(:permissions).through(:user_permissions) }
    it { is_expected.to have_many(:notes).dependent(:nullify) }
    it { is_expected.to have_many(:assigned_leads).dependent(:nullify) }
    it { is_expected.to have_many(:notification_preferences).dependent(:destroy) }
  end

  describe "callbacks" do
    it "creates default notification preferences for new admin users" do
      admin = create(:user, :admin)
      expect(admin.notification_preferences.pluck(:event_name)).to match_array(NotificationPreference::EVENTS)
    end

    it "does not create notification preferences for non-admin users" do
      user = create(:user)
      expect(user.notification_preferences).to be_empty
    end
  end

  describe "#full_name" do
    it "combines first and last name" do
      user = build(:user, first_name: "Jane", last_name: "Doe")
      expect(user.full_name).to eq("Jane Doe")
    end
  end

  describe "#can?" do
    let(:user) { create(:user) }

    it "returns true for admins regardless of permissions" do
      admin = create(:user, :admin)
      expect(admin.can?(:edit, :leads)).to be true
    end

    it "returns false when user has no matching permission" do
      expect(user.can?(:edit, :leads)).to be false
    end

    it "returns true when user has the specific permission" do
      user.grant!(:edit, :leads)
      expect(user.can?(:edit, :leads)).to be true
    end

    it "returns true when user has manage permission for the resource" do
      user.grant!(:manage, :leads)
      expect(user.can?(:edit, :leads)).to be true
      expect(user.can?(:delete, :leads)).to be true
    end

    it "does not grant cross-resource access" do
      user.grant!(:edit, :leads)
      expect(user.can?(:edit, :notes)).to be false
    end
  end

  describe "#grant!" do
    let(:user) { create(:user) }

    it "creates a permission and links it to the user" do
      expect { user.grant!(:view, :leads) }
        .to change { user.permissions.count }.by(1)
    end

    it "is idempotent" do
      user.grant!(:view, :leads)
      expect { user.grant!(:view, :leads) }
        .not_to change { user.permissions.count }
    end
  end

  describe "#revoke!" do
    let(:user) { create(:user) }

    it "removes the permission from the user" do
      user.grant!(:view, :leads)
      user.revoke!(:view, :leads)
      expect(user.can?(:view, :leads)).to be false
    end

    it "does nothing if the permission was not granted" do
      expect { user.revoke!(:view, :leads) }.not_to raise_error
    end
  end

  describe "#grant_all!" do
    let(:user) { create(:user) }

    it "grants manage permission for the resource" do
      user.grant_all!(:leads)
      expect(user.can?(:manage, :leads)).to be true
    end
  end
end
