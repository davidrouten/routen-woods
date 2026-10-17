require "rails_helper"

RSpec.describe Notifiers::SmsNotifier do
  include ActiveJob::TestHelper

  let!(:lead) { create(:lead) }
  let(:user) { create(:user) }

  describe "#deliver_later" do
    it "enqueues one job for that user" do
      notifier = described_class.new("new_lead", lead, user: user, extra: "x")

      expect { notifier.deliver_later }
        .to have_enqueued_job(SmsNotificationJob)
        .exactly(:once)
        .with("new_lead", lead.id, user.id, { extra: "x" })
    end
  end

  describe "via NotificationService" do
    it "enqueues one job per user with SMS enabled" do
      user2 = create(:user)
      create(:notification_preference, user: user, preferences: { "new_lead" => %w[sms] })
      create(:notification_preference, user: user2, preferences: { "new_lead" => %w[sms] })

      expect { NotificationService.notify(:new_lead, lead) }
        .to have_enqueued_job(SmsNotificationJob).exactly(:twice)
    end
  end
end
