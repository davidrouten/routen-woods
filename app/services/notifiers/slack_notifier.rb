module Notifiers
  class SlackNotifier < BaseNotifier
    def deliver_later
      SlackNotificationJob.perform_later(event_name, lead.id, context)
    end
  end
end
