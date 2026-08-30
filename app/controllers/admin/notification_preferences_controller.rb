module Admin
  class NotificationPreferencesController < BaseController
    before_action -> { require_permission!(:manage, :settings) }

    def index
      @preference = current_user.notification_preference ||
        current_user.build_notification_preference(preferences: NotificationPreference.default_preferences)
    end

    def create
      @preference = current_user.build_notification_preference(preferences: build_preferences)
      if @preference.save
        redirect_to admin_notification_preferences_path, notice: "Preferences updated."
      else
        render :index, status: :unprocessable_entity
      end
    end

    def update
      @preference = current_user.notification_preference
      @preference.preferences = build_preferences
      if @preference.save
        redirect_to admin_notification_preferences_path, notice: "Preferences updated."
      else
        render :index, status: :unprocessable_entity
      end
    end

    private

    def build_preferences
      NotificationPreference::EVENTS.each_with_object({}) do |event, hash|
        channels = params.dig(:preferences, event)
        hash[event] = channels.is_a?(Array) ? channels.reject(&:blank?) : []
      end
    end
  end
end
