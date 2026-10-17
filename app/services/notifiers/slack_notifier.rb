module Notifiers
  class SlackNotifier < BaseNotifier
    def self.enabled?
      Rails.configuration.x.slack_enabled
    end

    def self.shared?
      true
    end

    def deliver_later
      SlackNotificationJob.perform_later(event_name, lead.id, context)
    end
  end
end
