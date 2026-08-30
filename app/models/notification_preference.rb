class NotificationPreference < ApplicationRecord
  EVENTS = %w[new_lead status_changed lead_assigned daily_summary].freeze

  belongs_to :user

  validates :event_name, presence: true, inclusion: { in: EVENTS }
  validates :event_name, uniqueness: { scope: :user_id }

  def channels
    [].tap do |ch|
      ch << :email if email_enabled?
      ch << :sms if sms_enabled?
      ch << :slack if slack_enabled?
    end
  end
end
