require "rails_helper"

RSpec.describe SmsNotificationJob, type: :job do
  include ActiveJob::TestHelper

  let(:lead) { create(:lead, first_name: "Jane", last_name: "Doe") }
  let(:user) { create(:user, :admin, first_name: "John", last_name: "Smithers", phone: "+15555550100") }
  let(:messages) { double("messages", create: true) }
  let(:client) { instance_double(Twilio::REST::Client, messages: messages) }

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(client)
    allow(OpsAlert).to receive(:post)
  end

  describe "#perform" do
    it "texts only the given user" do
      create(:user, :admin, phone: "+15555550199")

      described_class.perform_now("new_lead", lead.id, user.id)

      expect(messages).to have_received(:create).once
      expect(messages).to have_received(:create).with(hash_including(to: "+15555550100"))
    end

    it "includes the lead's name in the message" do
      described_class.perform_now("new_lead", lead.id, user.id)

      expect(messages).to have_received(:create).with(hash_including(body: /Jane/))
    end

    it "interpolates values passed in the context" do
      described_class.perform_now("daily_summary", lead.id, user.id, { "count" => 4 })

      expect(messages).to have_received(:create).with(hash_including(body: "4 new leads today"))
    end

    it "does nothing when the user has no phone" do
      user.update!(phone: nil)

      described_class.perform_now("new_lead", lead.id, user.id)

      expect(messages).not_to have_received(:create)
    end
  end

  describe "retries" do
    it "retries once and reports the failure and the recovery" do
      allow(messages).to receive(:create).and_invoke(
        ->(*) { raise Twilio::REST::TwilioError, "Twilio is down" },
        ->(*) { true }
      )

      alerts = []
      allow(OpsAlert).to receive(:post) { |text| alerts << text }

      perform_enqueued_jobs { described_class.perform_later("new_lead", lead.id, user.id) }

      expect(messages).to have_received(:create).twice
      expect(alerts).to eq([
        "⚠️ Couldn't send SMS to John Smithers (New lead: Jane Doe). Retrying in 2 minutes. " \
          "Error: Twilio::REST::TwilioError: Twilio is down",
        "✅ Sent on retry: SMS to John Smithers (New lead: Jane Doe)"
      ])
    end

    it "gives up after one retry and reports it" do
      allow(messages).to receive(:create).and_raise(Twilio::REST::TwilioError, "Twilio is down")

      perform_enqueued_jobs { described_class.perform_later("new_lead", lead.id, user.id) }

      expect(messages).to have_received(:create).twice
      expect(OpsAlert).to have_received(:post).with(a_string_including("Couldn't send")).once
      expect(OpsAlert).to have_received(:post).with(a_string_including("❌ Gave up: SMS to John Smithers")).once
      expect(OpsAlert).not_to have_received(:post).with(a_string_including("Sent on retry"))
    end

    it "reports nothing when the first attempt succeeds" do
      perform_enqueued_jobs { described_class.perform_later("new_lead", lead.id, user.id) }

      expect(OpsAlert).not_to have_received(:post)
    end

    it "does not retry errors that are not delivery failures" do
      expect { described_class.perform_now("new_lead", 0, user.id) }
        .to raise_error(ActiveRecord::RecordNotFound)

      expect(OpsAlert).not_to have_received(:post)
    end
  end
end
