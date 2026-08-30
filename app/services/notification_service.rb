class NotificationService
  NOTIFIERS = {
    email: Notifiers::EmailNotifier,
    sms: Notifiers::SmsNotifier,
    slack: Notifiers::SlackNotifier
  }.freeze

  def self.notify(event_name, lead, **context)
    new(event_name, lead, **context).deliver
  end

  def initialize(event_name, lead, **context)
    @event_name = event_name.to_s
    @lead = lead
    @context = context
  end

  def deliver
    preferences = NotificationPreference.includes(:user).where(event_name: @event_name)

    preferences.each do |preference|
      preference.channels.each do |channel|
        notifier = NOTIFIERS[channel]
        next unless notifier
        notifier.new(@event_name, @lead, user: preference.user, **@context).deliver_later
      end
    end
  end
end
