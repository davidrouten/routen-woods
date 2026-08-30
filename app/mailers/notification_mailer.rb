class NotificationMailer < ApplicationMailer
  def notify
    @event = params[:event]
    @lead = params[:lead]
    @user = params[:user]
    @context = params[:context] || {}

    mail(
      to: @user.email,
      subject: I18n.t("notifications.#{@event}.email_subject", **mail_params)
    )
  end

  private

  def mail_params
    {
      name: @lead.first_name,
      service: @lead.service_names,
      status: @lead.status,
      from: @context[:from],
      to: @context[:to]
    }
  end
end
