class SmsNotificationJob < ApplicationJob
  include DeliveryRetry

  queue_as :notifications

  # One job per recipient, so a retry never re-texts someone who already got the message.
  def perform(event_name, lead_id, user_id, context = {})
    user = User.find(user_id)
    return if user.phone.blank?

    lead = Lead.find(lead_id)
    body = I18n.t(
      "notifications.#{event_name}.sms_body",
      name: lead.first_name,
      service: lead.service_names,
      status: lead.status,
      url: Rails.application.routes.url_helpers.admin_lead_url(lead, host: ENV.fetch("APP_HOST", "localhost:3000")),
      **context.symbolize_keys
    )

    client = Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"])
    client.messages.create(
      from: ENV["TWILIO_FROM_NUMBER"],
      to: user.phone,
      body: body
    )
  end

  def delivery_description
    event_name, lead_id, user_id = arguments
    recipient = User.find_by(id: user_id)&.full_name || "User##{user_id}"
    lead_name = Lead.find_by(id: lead_id)&.full_name_or_email || "Lead##{lead_id}"
    "SMS to #{recipient} (#{event_name.humanize}: #{lead_name})"
  end
end
