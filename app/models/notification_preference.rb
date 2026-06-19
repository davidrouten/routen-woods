class NotificationPreference < ApplicationRecord
  EVENTS = %w[new_lead status_changed lead_assigned daily_summary].freeze

  validates :event_name, presence: true, uniqueness: true, inclusion: { in: EVENTS }

  def channels
    [].tap do |ch|
      ch << :email if email_enabled?
      ch << :sms if sms_enabled?
      ch << :slack if slack_enabled?
    end
  end
end
