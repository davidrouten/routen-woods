# Operational alerts for us (not the client): always logged, and posted to the
# ops Slack channel when Slack is enabled and OPS_SLACK_WEBHOOK_URL is set. Never raises.
class OpsAlert
  def self.post(text)
    Rails.logger.warn("[OpsAlert] #{text}")

    url = ENV["OPS_SLACK_WEBHOOK_URL"]
    return if !Rails.configuration.x.slack_enabled || url.blank?

    Slack::Notifier.new(url).ping(text)
  rescue StandardError => e
    Rails.logger.error("[OpsAlert] Could not post to Slack: #{e.message}")
  end
end
