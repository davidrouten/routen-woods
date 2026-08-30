require "rails_helper"

RSpec.describe NotificationService do
  let(:lead) { create(:lead) }
  let(:user) { create(:user) }

  describe ".notify" do
    context "when a user has the event with email enabled" do
      before do
        create(:notification_preference,
          user: user,
          event_name: "status_changed",
          email_enabled: true,
          sms_enabled: false,
          slack_enabled: false
        )
      end

      it "delivers to that user" do
        notifier = instance_double(Notifiers::EmailNotifier, deliver_later: true)
        allow(Notifiers::EmailNotifier).to receive(:new).and_return(notifier)

        NotificationService.notify(:status_changed, lead)

        expect(Notifiers::EmailNotifier).to have_received(:new)
          .with("status_changed", lead, user: user)
        expect(notifier).to have_received(:deliver_later)
      end
    end

    context "when multiple users have preferences" do
      let(:user2) { create(:user) }

      before do
        create(:notification_preference, user: user, event_name: "status_changed", email_enabled: true, slack_enabled: false)
        create(:notification_preference, user: user2, event_name: "status_changed", email_enabled: true, slack_enabled: false)
      end

      it "delivers to each user individually" do
        notifier = instance_double(Notifiers::EmailNotifier, deliver_later: true)
        allow(Notifiers::EmailNotifier).to receive(:new).and_return(notifier)

        NotificationService.notify(:status_changed, lead)

        expect(Notifiers::EmailNotifier).to have_received(:new).twice
      end
    end

    context "when one user has email disabled for the event" do
      let(:user2) { create(:user) }

      before do
        create(:notification_preference, user: user, event_name: "status_changed", email_enabled: true, slack_enabled: false)
        create(:notification_preference, user: user2, event_name: "status_changed", email_enabled: false, slack_enabled: false)
      end

      it "only delivers to the user with it enabled" do
        notifier = instance_double(Notifiers::EmailNotifier, deliver_later: true)
        allow(Notifiers::EmailNotifier).to receive(:new).and_return(notifier)

        NotificationService.notify(:status_changed, lead)

        expect(Notifiers::EmailNotifier).to have_received(:new).once
          .with("status_changed", lead, user: user)
      end
    end

    context "when no preferences exist for the event" do
      it "does not deliver anything" do
        expect(Notifiers::EmailNotifier).not_to receive(:new)
        NotificationService.notify(:status_changed, lead)
      end
    end

    context "when all channels are disabled" do
      before do
        create(:notification_preference,
          user: user,
          event_name: "status_changed",
          email_enabled: false,
          sms_enabled: false,
          slack_enabled: false
        )
      end

      it "does not deliver anything" do
        expect(Notifiers::EmailNotifier).not_to receive(:new)
        expect(Notifiers::SmsNotifier).not_to receive(:new)
        expect(Notifiers::SlackNotifier).not_to receive(:new)

        NotificationService.notify(:status_changed, lead)
      end
    end
  end
end
