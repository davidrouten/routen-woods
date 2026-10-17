module Notifiers
  class SmsNotifier < BaseNotifier
    def deliver_later
      SmsNotificationJob.perform_later(event_name, lead.id, context[:user].id, context.except(:user))
    end
  end
end
