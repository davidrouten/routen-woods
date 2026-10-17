class SlackNotificationJob < ApplicationJob
  include DeliveryRetry

  queue_as :notifications

  def perform(event_name, lead_id, context = {})
    webhook_url = ENV["SLACK_WEBHOOK_URL"]
    return if !Rails.configuration.x.slack_enabled || webhook_url.blank?

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
  end

  def delivery_description
    event_name, lead_id = arguments
    lead_name = Lead.find_by(id: lead_id)&.full_name_or_email || "Lead##{lead_id}"
    "Slack post to the leads channel (#{event_name.humanize}: #{lead_name})"
  end
end
