require "rails_helper"

RSpec.describe OpsAlert do
  let(:slack) { instance_double(Slack::Notifier, ping: true) }

  around do |example|
    original = ENV["OPS_SLACK_WEBHOOK_URL"]
    Rails.configuration.x.slack_enabled = true
    example.run
  ensure
    ENV["OPS_SLACK_WEBHOOK_URL"] = original
    Rails.configuration.x.slack_enabled = false
  end

  before do
    allow(Slack::Notifier).to receive(:new).and_return(slack)
    allow(Rails.logger).to receive(:warn)
    allow(Rails.logger).to receive(:error)
  end

  it "always logs the alert" do
    ENV["OPS_SLACK_WEBHOOK_URL"] = nil

    described_class.post("something broke")

    expect(Rails.logger).to have_received(:warn).with("[OpsAlert] something broke")
    expect(slack).not_to have_received(:ping)
  end

  it "posts to the ops Slack channel when configured" do
    ENV["OPS_SLACK_WEBHOOK_URL"] = "https://hooks.slack.test/ops"

    described_class.post("something broke")

    expect(Slack::Notifier).to have_received(:new).with("https://hooks.slack.test/ops")
    expect(slack).to have_received(:ping).with("something broke")
  end

  it "only logs when Slack is disabled" do
    ENV["OPS_SLACK_WEBHOOK_URL"] = "https://hooks.slack.test/ops"
    Rails.configuration.x.slack_enabled = false

    described_class.post("something broke")

    expect(Rails.logger).to have_received(:warn).with("[OpsAlert] something broke")
    expect(slack).not_to have_received(:ping)
  end

  it "never raises, even when Slack is down" do
    ENV["OPS_SLACK_WEBHOOK_URL"] = "https://hooks.slack.test/ops"
    allow(slack).to receive(:ping).and_raise(Slack::Notifier::APIError, "500")

    expect { described_class.post("something broke") }.not_to raise_error
    expect(Rails.logger).to have_received(:error).with(/Could not post to Slack/)
  end
end
