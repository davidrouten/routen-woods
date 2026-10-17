require "rails_helper"

RSpec.describe SlackNotificationJob, type: :job do
  include ActiveJob::TestHelper

  let(:lead) { create(:lead, first_name: "Jane", last_name: "Doe") }
  let(:slack) { instance_double(Slack::Notifier, ping: true) }

  around do |example|
    original = ENV["SLACK_WEBHOOK_URL"]
    ENV["SLACK_WEBHOOK_URL"] = "https://hooks.slack.test/leads"
    Rails.configuration.x.slack_enabled = true
    example.run
  ensure
    ENV["SLACK_WEBHOOK_URL"] = original
    Rails.configuration.x.slack_enabled = false
  end

  before do
    allow(Slack::Notifier).to receive(:new).and_return(slack)
    allow(OpsAlert).to receive(:post)
  end

  it "posts the lead to the leads channel" do
    described_class.perform_now("new_lead", lead.id)

    expect(slack).to have_received(:ping).with(/Jane/)
  end

  it "does nothing when Slack is disabled" do
    Rails.configuration.x.slack_enabled = false

    described_class.perform_now("new_lead", lead.id)

    expect(slack).not_to have_received(:ping)
  end

  it "does nothing when no webhook is configured" do
    ENV["SLACK_WEBHOOK_URL"] = nil

    described_class.perform_now("new_lead", lead.id)

    expect(slack).not_to have_received(:ping)
  end

  it "retries once and reports the failure and the recovery" do
    allow(slack).to receive(:ping).and_invoke(
      ->(*) { raise Slack::Notifier::APIError, "500" },
      ->(*) { true }
    )

    alerts = []
    allow(OpsAlert).to receive(:post) { |text| alerts << text }

    perform_enqueued_jobs { described_class.perform_later("new_lead", lead.id) }

    expect(slack).to have_received(:ping).twice
    expect(alerts).to eq([
      "⚠️ Couldn't send Slack post to the leads channel (New lead: Jane Doe). Retrying in 2 minutes. " \
        "Error: Slack::Notifier::APIError: 500",
      "✅ Sent on retry: Slack post to the leads channel (New lead: Jane Doe)"
    ])
  end

  it "retries on network timeouts" do
    allow(slack).to receive(:ping).and_invoke(->(*) { raise Net::OpenTimeout }, ->(*) { true })

    perform_enqueued_jobs { described_class.perform_later("new_lead", lead.id) }

    expect(slack).to have_received(:ping).twice
  end
end
