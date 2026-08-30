require "rails_helper"

RSpec.describe NotificationPreference, type: :model do
  describe "validations" do
    subject { build(:notification_preference) }

    it { is_expected.to validate_presence_of(:event_name) }
    it { is_expected.to validate_uniqueness_of(:event_name).scoped_to(:user_id) }
    it { is_expected.to validate_inclusion_of(:event_name).in_array(NotificationPreference::EVENTS) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "#channels" do
    it "returns enabled channels" do
      pref = build(:notification_preference, email_enabled: true, sms_enabled: false, slack_enabled: true)
      expect(pref.channels).to eq([:email, :slack])
    end

    it "returns empty array when nothing enabled" do
      pref = build(:notification_preference, email_enabled: false, sms_enabled: false, slack_enabled: false)
      expect(pref.channels).to be_empty
    end
  end
end
