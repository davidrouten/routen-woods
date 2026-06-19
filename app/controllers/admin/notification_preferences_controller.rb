module Admin
  class NotificationPreferencesController < BaseController
    before_action -> { require_permission!(:manage, :settings) }

    def index
      @preferences = NotificationPreference.all
    end

    def update
      @preference = NotificationPreference.find(params[:id])
      if @preference.update(preference_params)
        redirect_to admin_notification_preferences_path, notice: "Preferences updated."
      else
        @preferences = NotificationPreference.all
        render :index, status: :unprocessable_entity
      end
    end

    private

    def preference_params
      params.require(:notification_preference).permit(:email_enabled, :sms_enabled, :slack_enabled)
    end
  end
end
