module Notifiers
  class SmsNotifier < BaseNotifier
    def deliver_later
      SmsNotificationJob.perform_later(event_name, lead.id, context)
    end
  end
end
