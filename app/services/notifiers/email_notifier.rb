module Notifiers
  class EmailNotifier < BaseNotifier
    def deliver_later
      NotificationMailer.with(
        event: event_name,
        lead: lead,
        user: context[:user],
        context: context.except(:user)
      ).notify.deliver_later
    end
  end
end
