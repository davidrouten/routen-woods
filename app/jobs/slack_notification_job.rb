class SlackNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(event_name, lead_id, context = {})
    webhook_url = ENV["SLACK_WEBHOOK_URL"]
    return if webhook_url.blank?

    lead = Lead.find(lead_id)
    text = I18n.t(
      "notifications.#{event_name}.slack_text",
      name: lead.first_name,
      service: lead.service_names,
      status: lead.status,
      **context.symbolize_keys
    )

    notifier = Slack::Notifier.new(webhook_url)
    notifier.ping(text)
  rescue Slack::Notifier::APIError => e
    Rails.logger.error("Slack notification failed: #{e.message}")
  end
end
