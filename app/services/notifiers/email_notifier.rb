module Notifiers
  class EmailNotifier < BaseNotifier
    def deliver_later
      NotificationMailer.with(
        event: event_name,
        lead: lead,
        context: context
      ).notify.deliver_later
    end
  end
end
