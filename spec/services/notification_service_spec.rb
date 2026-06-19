require "rails_helper"

RSpec.describe NotificationService do
  let(:lead) { create(:lead) }

  describe ".notify" do
    context "when preference exists with enabled channels" do
      before do
        create(:notification_preference,
          event_name: "status_changed",
          email_enabled: true,
          sms_enabled: false,
          slack_enabled: false
        )
      end

      it "delivers to enabled channels" do
        notifier = instance_double(Notifiers::EmailNotifier, deliver_later: true)
        allow(Notifiers::EmailNotifier).to receive(:new).and_return(notifier)

        NotificationService.notify(:status_changed, lead)

        expect(notifier).to have_received(:deliver_later)
      end
    end

    context "when no preference exists for the event" do
      it "does not raise" do
        expect { NotificationService.notify(:unknown_event, lead) }.not_to raise_error
      end
    end

    context "when all channels are disabled" do
      before do
        create(:notification_preference,
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
