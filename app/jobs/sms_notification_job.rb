class SmsNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(event_name, lead_id, context = {})
    lead = Lead.find(lead_id)
    admin_phones = User.where(admin: true).where.not(phone: nil).pluck(:phone)
    return if admin_phones.empty?

    body = I18n.t(
      "notifications.#{event_name}.sms_body",
      name: lead.first_name,
      service: lead.service_names,
      status: lead.status,
      url: Rails.application.routes.url_helpers.admin_lead_url(lead, host: ENV.fetch("APP_HOST", "localhost:3000"))
    )

    client = Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"])
    admin_phones.each do |phone|
      client.messages.create(
        from: ENV["TWILIO_FROM_NUMBER"],
        to: phone,
        body: body
      )
    rescue Twilio::REST::TwilioError => e
      Rails.logger.error("SMS to #{phone} failed: #{e.message}")
    end
  end
end
