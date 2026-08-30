class NotificationPreference < ApplicationRecord
  EVENTS = %w[new_lead status_changed lead_assigned daily_summary].freeze
  CHANNELS = %w[email sms slack].freeze

  belongs_to :user

  validates :user_id, uniqueness: true
  validate :preferences_format

  def self.default_preferences
    EVENTS.each_with_object({}) { |event, hash| hash[event] = %w[email] }
  end

  def channels_for(event)
    channels = preferences.fetch(event.to_s, [])
    channels.filter_map { |ch| ch.to_sym if CHANNELS.include?(ch) }
  end

  private

  def preferences_format
    return unless preferences.is_a?(Hash)

    preferences.each do |event, channels|
      unless EVENTS.include?(event)
        errors.add(:preferences, "contains unknown event: #{event}")
      end
      unless channels.is_a?(Array) && channels.all? { |ch| CHANNELS.include?(ch) }
        errors.add(:preferences, "contains invalid channels for #{event}")
      end
    end
  end
end
