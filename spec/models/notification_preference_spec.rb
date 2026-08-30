require "rails_helper"

RSpec.describe NotificationPreference, type: :model do
  describe "validations" do
    subject { build(:notification_preference) }

    it { is_expected.to validate_uniqueness_of(:user_id) }

    it "rejects unknown events" do
      pref = build(:notification_preference, preferences: { "bogus" => ["email"] })
      expect(pref).not_to be_valid
      expect(pref.errors[:preferences]).to include(/unknown event/)
    end

    it "rejects invalid channels" do
      pref = build(:notification_preference, preferences: { "new_lead" => ["carrier_pigeon"] })
      expect(pref).not_to be_valid
      expect(pref.errors[:preferences]).to include(/invalid channels/)
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe ".default_preferences" do
    it "sets email for all events" do
      defaults = NotificationPreference.default_preferences
      expect(defaults.keys).to match_array(NotificationPreference::EVENTS)
      defaults.each_value { |channels| expect(channels).to eq(%w[email]) }
    end
  end

  describe "#channels_for" do
    it "returns enabled channels for the event" do
      pref = build(:notification_preference, preferences: { "new_lead" => %w[email slack] })
      expect(pref.channels_for(:new_lead)).to eq([:email, :slack])
    end

    it "returns empty array for events with no channels" do
      pref = build(:notification_preference, preferences: { "new_lead" => [] })
      expect(pref.channels_for(:new_lead)).to eq([])
    end

    it "returns empty array for unconfigured events" do
      pref = build(:notification_preference, preferences: {})
      expect(pref.channels_for(:new_lead)).to eq([])
    end
  end
end
