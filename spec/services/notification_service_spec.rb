require "rails_helper"

RSpec.describe NotificationService do
  let(:lead) { create(:lead) }
  let(:user) { create(:user) }

  describe ".notify" do
    context "when a user has email enabled for the event" do
      before do
        create(:notification_preference,
          user: user,
          preferences: { "status_changed" => %w[email] }
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

    context "when multiple users have the event enabled" do
      let(:user2) { create(:user) }

      before do
        create(:notification_preference, user: user, preferences: { "status_changed" => %w[email] })
        create(:notification_preference, user: user2, preferences: { "status_changed" => %w[email] })
      end

      it "delivers to each user individually" do
        notifier = instance_double(Notifiers::EmailNotifier, deliver_later: true)
        allow(Notifiers::EmailNotifier).to receive(:new).and_return(notifier)

        NotificationService.notify(:status_changed, lead)

        expect(Notifiers::EmailNotifier).to have_received(:new).twice
      end
    end

    context "when one user has the event and another does not" do
      let(:user2) { create(:user) }

      before do
        create(:notification_preference, user: user, preferences: { "status_changed" => %w[email] })
        create(:notification_preference, user: user2, preferences: { "status_changed" => [] })
      end

      it "only delivers to the user with it enabled" do
        notifier = instance_double(Notifiers::EmailNotifier, deliver_later: true)
        allow(Notifiers::EmailNotifier).to receive(:new).and_return(notifier)

        NotificationService.notify(:status_changed, lead)

        expect(Notifiers::EmailNotifier).to have_received(:new).once
          .with("status_changed", lead, user: user)
      end
    end

    context "when no preferences exist" do
      it "does not deliver anything" do
        expect(Notifiers::EmailNotifier).not_to receive(:new)
        NotificationService.notify(:status_changed, lead)
      end
    end

    context "when user has no channels for the event" do
      before do
        create(:notification_preference,
          user: user,
          preferences: { "status_changed" => [] }
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
